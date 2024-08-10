defmodule Impostor.Game do
  @enforce_keys [:players]
  defstruct message_id: nil, players: [], state: :lobby

  @dictionary ~w[
    ardoise
    fleur
    herbe
    lame
    oiseau
    pelle
    pique
    robe
    savon
    sens
  ]

  def new(player) do
    %__MODULE__{players: [player]}
  end

  def join(%{players: players, state: :lobby} = game, player) do
    if player in players do
      {:error, "player already joined #{inspect(player)}"}
    else
      game = Map.update(game, :players, [], &List.insert_at(&1, -1, player))

      {:ok, game}
    end
  end

  def join(_game, _player), do: {:error, "game already started"}

  def start(%{state: :lobby, players: players} = game) do
    [secret_word, impostor_word] =
      @dictionary |> Enum.shuffle() |> Enum.take(2)

    players =
      players
      |> Enum.shuffle()
      |> then(fn [impostor | players] ->
        players = Enum.map(players, &Map.put(&1, :secret_word, secret_word))
        impostor = Map.put(impostor, :secret_word, impostor_word)

        [impostor | players]
      end)
      |> Enum.shuffle()

    game =
      game
      |> Map.put(:state, :started)
      |> Map.put(:players, players)

    {:ok, game}
  end

  def start(_game), do: {:error, "game already started"}

  def play_word(%__MODULE__{state: state} = game) when state == :lobby do
    {:error, "cannot play words yet, the game hasn':w
      't started"}
  end

  def play_word(
        %__MODULE__{players: [%{id: first_player_id} = player | players], state: state} = game,
        player_id,
        word
      )
      when state == :started and first_player_id == player_id do
    game =
      player
      |> Map.update!(:words, &(List.wrap(&1) |> List.insert_at(-1, word)))
      |> then(&List.insert_at(players, -1, &1))
      |> then(&Map.put(game, :players, &1))

    {:ok, game}
  end

  def play_word(%__MODULE__{} = _game, player_id, _word) do
    {:error, "this is not #{player_id}'s turn"}
  end
end
