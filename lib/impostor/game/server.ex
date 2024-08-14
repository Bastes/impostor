defmodule Impostor.Game.Server do
  use GenServer

  def new(player) do
    GenServer.call(__MODULE__, {:new, player})
  end

  def set_message_id(message_id) do
    GenServer.call(__MODULE__, {:set_message_id, message_id})
  end

  def join(player) do
    GenServer.call(__MODULE__, {:join, player})
  end

  def start() do
    GenServer.call(__MODULE__, :start)
  end

  def play_word(player_id, word) do
    GenServer.call(__MODULE__, {:play_word, player_id, word})
  end

  def players() do
    GenServer.call(__MODULE__, :players)
  end

  def game() do
    GenServer.call(__MODULE__, :game)
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

  def handle_call({:set_message_id, message_id}, _from, game) do
    game = Map.put(game, :message_id, message_id)

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

  def handle_call({:play_word, player_id, word}, _from, game) do
    Impostor.Game.play_word(game, player_id, word)
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

  def handle_call(:game, _from, game) do
    {:reply, game, game}
  end
end
