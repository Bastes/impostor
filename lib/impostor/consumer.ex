defmodule Impostor.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    IO.inspect(msg, label: "msg")

    case msg.content do
      "!new_impostor_game" ->
        embed =
          %Embed{}
          |> Embed.put_title("New Game of Impostor")
          |> Embed.put_description(
            """
            Let's prepare your new game.

            Players:
            #{msg.author.global_name} (@#{msg.author.username})
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
