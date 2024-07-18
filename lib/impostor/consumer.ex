defmodule Impostor.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    IO.inspect(msg, label: "msg")

    case msg.content do
      "!new_impostor_game" ->
        author = msg.author
        player = %{
          id: author.id,
          global_name: author.global_name,
          username: author.username
        }
        players =
          GenServer.call(Impostor.Game, {:join, player})
          |> Enum.map(fn %{global_name: global_name, username: username} ->
            "#{global_name} (@#{username})"
          end)
          |> Enum.join("\n")

        embed =
          %Embed{}
          |> Embed.put_title("New Game of Impostor")
          |> Embed.put_description(
            """
            Let's prepare your new game.

            Players:
            #{players}
            """
          )

        Api.create_message(
          msg.channel_id,
          embeds: [embed]
        )

      _ ->
        :noop
    end
  end
end
