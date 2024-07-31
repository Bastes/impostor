defmodule Impostor.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!new_impostor_game" ->
        {:ok, game} =
          msg.author
          |> new_player()
          |> Impostor.Game.Server.new()

        game
        |> render()
        |> then(&Api.create_message(msg.channel_id, &1))

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
              for player <- players,
                  dm_channel = Api.create_dm!(player.id) do
                message =
                  case player.version do
                    nil ->
                      player.secret_word

                    version ->
                      "#{version} - #{player.secret_word}"
                  end

                Api.create_message(dm_channel.id, message)
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
    |> Impostor.Game.Player.new()
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
    |> Impostor.Game.Player.new()
  end

  defp render(%{players: players, state: :lobby} = _game) do
    players =
      players
      |> Stream.map(&Impostor.Game.Player.screen_name/1)
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

  defp render(%{players: players, state: :started} = _game) do
    [player_1_nick | _] =
      players_nicks =
      Enum.map(players, &Impostor.Game.Player.screen_name/1)

    players =
      Enum.map(players_nicks, &("* " <> &1))
      |> Enum.join("\n")

    embed =
      %Embed{}
      |> Embed.put_title("Game of Impostor in progress.")
      |> Embed.put_description("""
      Players:
      #{players}

      #{player_1_nick}, this is your turn!

      Give your word with the `!word` command:

      ```
      !word [your word here]
      ```
      """)

    [embeds: [embed]]
  end
end
