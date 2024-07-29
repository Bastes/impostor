defmodule Impostor.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!new_impostor_game" ->
        msg.author
        |> new_player([])
        |> Impostor.Game.new()
        |> handle_game_errors()
        |> render(msg.channel_id)

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
        interaction.user
        |> new_player([])
        |> Impostor.Game.join()
        |> handle_game_errors()
        |> render(interaction.channel_id)

        Api.create_interaction_response(
          interaction,
          %{type: 4, data: %{content: "Very well, you are all joined", flags: @ephemeral}}
        )

      _ ->
        :ignore
    end
  end

  defp handle_game_errors({:ok, players}), do: players

  defp handle_game_errors({:error, error, players}) do
    IO.puts("Error: #{error}")

    players
  end

  defp new_player(author, _players) do
    player = %{
      id: author.id,
      global_name: author.global_name,
      username: author.username
    }
  end

  defp render(players, channel_id) do
    players =
      players
      |> Enum.map(fn %{global_name: global_name, username: username} ->
        "#{global_name} (@#{username})"
      end)
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

    Api.create_message(
      channel_id,
      embeds: [embed],
      components: [component]
    )
  end
end
