defmodule Impostor.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!new_impostor_game" ->
        msg.author
        |> new_player()
        |> Impostor.Game.new()
        |> handle_game_errors()
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
        players = Impostor.Game.players()

        interaction.user
        |> new_player(players)
        |> Impostor.Game.join()
        |> case do
          {:ok, players} ->
            players
            |> render()
            |> then(&Api.edit_message(interaction.channel_id, interaction.message.id, &1))

            Api.create_interaction_response(
              interaction,
              %{type: 4, data: %{content: "Very well, you are all joined", flags: @ephemeral}}
            )

          {:error, error, _players} ->
            Api.create_interaction_response(
              interaction,
              %{type: 4, data: %{content: "⚠️ #{error}", flags: @ephemeral}}
            )
        end

      _ ->
        :ignore
    end
  end

  defp handle_game_errors({:ok, players}), do: players

  defp handle_game_errors({:error, error, players}) do
    IO.puts("Error: #{error}")

    players
  end

  defp new_player(%{id: id} = author, players \\ []) do
    player_data = Map.take(author, [:id, :global_name, :username])

    if Application.get_env(:impostor, :mono_allowed) do
      version =
        players
        |> Stream.filter(&(&1.id == id))
        |> Enum.max_by(& &1.version, fn -> %{version: 0} end)
        |> then(& &1.version)

      Map.put(player_data, :version, version + 1)
    else
      player_data
    end
    |> Impostor.Game.Player.new()
  end

  defp render(players) do
    players =
      players
      |> Enum.reverse()
      |> Stream.map(&Impostor.Game.Player.screen_name/1)
      |> Enum.join("\n")

    embed =
      %Embed{}
      |> Embed.put_title("New Game of Impostor")
      |> Embed.put_description("""
      Let's prepare your new game.

      Players:
      #{players}
      """)

    component =
      Nostrum.Struct.Component.ActionRow.action_row(
        components: [
          Nostrum.Struct.Component.Button.interaction_button(
            "Join the game",
            "JOIN",
            style: Nostrum.Constants.ButtonStyle.primary()
          )
        ]
      )

    [
      embeds: [embed],
      components: [component]
    ]
  end
end
