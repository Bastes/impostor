defmodule Impostor.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Embed
  alias Impostor.Game.Player

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!new_impostor_game" ->
        {:ok, game} =
          msg.author
          |> new_player()
          |> Impostor.Game.Server.new()

        {:ok, message} =
          game
          |> render()
          |> then(&Api.create_message(msg.channel_id, &1))

        {:ok, _game} =
          Impostor.Game.Server.set_message_id(message.id)

      "!word " <> word ->
        Api.delete_message(msg)

        author_id = msg.author.id

        {:ok, _game} =
          with {:ok, game} <- Impostor.Game.Server.play_word(author_id, word) do
            game
            |> render()
            |> then(&Api.edit_message(msg.channel_id, game.message_id, &1))
          else
            {:error, message} ->
              dm_channel = Api.create_dm!(author_id)

              Api.create_message(dm_channel.id, "error: #{message}")

              {:error, message}
          end

      _ ->
        :noop
    end
  end

  # ephemeral flag allows to send a private, ephemeral reply
  @ephemeral 1_000_000
  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    IO.inspect(interaction, label: "interaction")

    case interaction.data.custom_id do
      "JOIN" ->
        player = new_player(interaction.user)

        case Impostor.Game.Server.players() do
          [^player | _] ->
            with {:ok, %{players: players} = game} <- Impostor.Game.Server.start() do
              for player <- players do
                Task.start_link(fn ->
                  dm_channel = Api.create_dm!(Player.discord_id(player))

                  message =
                    case player.version do
                      nil ->
                        player.secret_word

                      version ->
                        "#{version} - #{player.secret_word}"
                    end

                  Api.create_message(dm_channel.id, message)
                end)
              end

              {:ok, game}
            end

          _players ->
            Impostor.Game.Server.join(player)
        end
        |> case do
          {:ok, game} ->
            game
            |> render()
            |> then(&Map.new/1)
            |> then(&Api.create_interaction_response(interaction, %{type: 7, data: &1}))

          {:error, error} ->
            Api.create_interaction_response(
              interaction,
              %{type: 4, data: %{content: "⚠️ #{error}", flags: @ephemeral}}
            )
        end

      "CLONE" ->
        players = Impostor.Game.Server.players()

        {:ok, game} =
          interaction.user
          |> new_clone(players)
          |> Impostor.Game.Server.join()

        game
        |> render()
        |> then(&Map.new/1)
        |> then(&Api.create_interaction_response(interaction, %{type: 7, data: &1}))

      _ ->
        :ignore
    end
  end

  defp new_player(author) do
    author
    |> Map.take([:id, :global_name, :username])
    |> Player.Standard.new()
  end

  defp new_clone(%{id: id} = author, players) do
    version =
      players
      |> Stream.filter(&(&1.id == id))
      |> Stream.map(&(&1.version || 0))
      |> Enum.max(fn -> %{version: 0} end)

    author
    |> Map.take([:id, :global_name, :username])
    |> Map.put(:version, version + 1)
    |> Player.Duplicable.new()
  end

  defp render(%{players: players, state: :phase_0_lobby} = _game) do
    players =
      players
      |> Stream.map(&Player.screen_name/1)
      |> Stream.map(&("* " <> &1))
      |> Enum.join("\n")

    embed =
      %Embed{}
      |> Embed.put_title("New Game of Impostor")
      |> Embed.put_description("""
      Let's prepare your new game.

      Players:
      #{players}
      """)

    buttons = [
      Nostrum.Struct.Component.Button.interaction_button(
        "Join the game",
        "JOIN",
        style: Nostrum.Constants.ButtonStyle.primary()
      )
    ]

    buttons =
      if Application.get_env(:impostor, :mono_allowed) do
        [
          Nostrum.Struct.Component.Button.interaction_button(
            "Clone me!",
            "CLONE",
            style: Nostrum.Constants.ButtonStyle.danger()
          )
          | buttons
        ]
      else
        buttons
      end

    component =
      Nostrum.Struct.Component.ActionRow.action_row(components: buttons)

    [
      embeds: [embed],
      components: [component]
    ]
  end

  defp render(%{players: [player | _] = players, state: :phase_1_words} = _game) do
    [player_1_nick | _] =
      players_nicks_and_words =
      Enum.map(players, &Player.screen_name_and_words/1)

    players =
      Enum.map(players_nicks_and_words, &("* " <> &1))
      |> Enum.join("\n")

    embed =
      %Embed{}
      |> Embed.put_title("Game of Impostor in progress.")
      |> Embed.put_description("""
      Players:
      #{players}

      #{player_1_nick}, this is your turn!

      Give your word ##{length(player.words || []) + 1} with the `!word` command:

      ```
      !word [your word here]
      ```
      """)

    [embeds: [embed], components: []]
  end

  defp render(%{players: players, state: :phase_2_point} = _game) do
    players_nicks_and_words =
      Enum.map(players, &Player.screen_name_and_words/1)

    players_nicks_and_words =
      Enum.map(players_nicks_and_words, &("* " <> &1))
      |> Enum.join("\n")

    embed =
      %Embed{}
      |> Embed.put_title("Voting for the impostor.")
      |> Embed.put_description("""
      Players:
      #{players_nicks_and_words}

      Now everyone, point to whom you believe is the impostor please...
      """)

    components =
      players
      |> Stream.map(fn player ->
        nick = Player.screen_name(player)

        Nostrum.Struct.Component.Button.interaction_button(
          "#{nick}",
          "IMPOSTOR_IS_#{Player.game_id(player)}",
          style: Nostrum.Constants.ButtonStyle.primary()
        )
      end)
      |> Stream.chunk_every(5)
      |> Enum.map(&Nostrum.Struct.Component.ActionRow.action_row(components: &1))

    [embeds: [embed], components: components]
  end
end
