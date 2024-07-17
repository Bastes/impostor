defmodule Impostor.Application do
  use Application

  def start(_type, _args) do
    children = [
      Impostor.Consumer
    ]

    opts = [strategy: :one_for_one, name: DiscordBot.Application.Sup]

    Supervisor.start_link(children, opts)
  end
end

defmodule Impostor.Consumer do
  use Nostrum.Consumer

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!word" ->
        Nostrum.Api.create_message(msg.channel_id, "Word, brother!")
    end
  end
end

defmodule Impostor do
  @moduledoc """
  Documentation for `Impostor`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Impostor.hello()
      :world

  """
  def hello do
    :world
  end
end
