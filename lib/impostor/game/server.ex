defmodule Impostor.Game.Server do
  use GenServer

  def new(player) do
    GenServer.call(__MODULE__, {:new, player})
  end

  def join(player) do
    GenServer.call(__MODULE__, {:join, player})
  end

  def start() do
    GenServer.call(__MODULE__, :start)
  end

  def players() do
    GenServer.call(__MODULE__, :players)
  end

  def start_link(game) when is_list(game) do
    GenServer.start_link(__MODULE__, game, name: __MODULE__)
  end

  @impl true
  def init(game) when is_list(game) do
    {:ok, game}
  end

  @impl true
  def handle_call({:new, player}, _from, _game) do
    game = Impostor.Game.new(player)

    {:reply, {:ok, game}, game}
  end

  def handle_call({:join, player}, _from, game) do
    Impostor.Game.join(game, player)
    |> case do
      {:ok, game} ->
        {:reply, {:ok, game}, game}

      {:error, error} ->
        {:reply, {:error, error}, game}
    end
  end

  def handle_call(:start, _from, game) do
    Impostor.Game.start(game)
    |> case do
      {:ok, game} ->
        {:reply, {:ok, game}, game}

      {:error, error} ->
        {:reply, {:error, error}, game}
    end
  end

  def handle_call(:players, _from, %{players: players} = game) do
    {:reply, players, game}
  end
end
