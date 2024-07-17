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

