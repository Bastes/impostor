defmodule Impostor.Game do
  use GenServer

  def new(player) do
    GenServer.call(Impostor.Game, {:new, player})
  end

  def join(player) do
    GenServer.call(Impostor.Game, {:join, player})
  end

  def start_link(game) when is_list(game) do
    GenServer.start_link(__MODULE__, game, name: __MODULE__)
  end

  @impl true
  def init(game) when is_list(game) do
    {:ok, game}
  end

  @impl true
  def handle_call({:new, player}, _from, _players) do
    players = [player]
    {:reply, {:ok, players}, players}
  end

  def handle_call({:join, player}, _from, players) do
    if player in players do
      {:reply, {:error, "player already joined #{inspect(player)}", players}, players}
    else
      players = [player | players]
      {:reply, {:ok, players}, players}
    end
  end
end
