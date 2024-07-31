defmodule Impostor.Game do
  @enforce_keys [:players]
  defstruct players: []

  def new(player) do
    %__MODULE__{players: [player]}
  end

  def join(%{players: players} = game, player) do
    if player in players do
      {:error, "player already joined #{inspect(player)}"}
    else
      game = Map.update(game, :players, [], &[player | &1])

      {:ok, game}
    end
  end
end
