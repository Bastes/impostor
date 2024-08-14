defmodule Impostor.Game.Player.Duplicable do
  alias Impostor.Game.Player.Standard

  @enforce_keys [:id, :global_name, :username, :version]
  defstruct [:id, :global_name, :username, :secret_word, :words, :version]

  def new(%{id: _, global_name: _, username: _, version: _} = data) do
    struct(__MODULE__, data)
  end

  def screen_name(global_name, username, version) do
    Standard.screen_name(global_name, username <> " - #{version}")
  end
end

defimpl Impostor.Game.Player, for: Impostor.Game.Player.Duplicable do
  alias Impostor.Game.Player.Standard

  def screen_name(%{global_name: global_name, username: username, version: version}) do
    @for.screen_name(global_name, username, version)
  end

  def screen_name_and_words(player), do: Standard.screen_name_and_words(player)

  def discord_id(%{id: id}), do: id
  def game_id(%{id: id, version: version}), do: "#{id}-#{version}"
  def words(%{words: words}), do: List.wrap(words)
end
