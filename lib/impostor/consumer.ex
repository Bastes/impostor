defmodule Impostor.Consumer do
  use Nostrum.Consumer

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!word" ->
        Nostrum.Api.create_message(msg.channel_id, "Word, brother!")
    end
  end
end
