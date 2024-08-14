defmodule Impostor.Game.Player.Standard do
  alias Impostor.Game.Player

  @enforce_keys [:id, :global_name, :username]
  defstruct [:id, :global_name, :username, :secret_word, :words, :version]

  def new(%{id: _, global_name: _, username: _} = data) do
    struct(__MODULE__, data)
  end

  def screen_name(global_name, username) do
    "#{global_name} (@#{username})"
  end

  def screen_word_list(player) do
    player
    |> Player.words()
    |> Enum.join(" - ")
  end

  def screen_name_and_words(%{words: words} = player) when is_list(words) do
    "#{Player.screen_name(player)} [ #{screen_word_list(player)} ]"
  end

  def screen_name_and_words(%{} = player), do: Player.screen_name(player)
end

defimpl Impostor.Game.Player, for: Impostor.Game.Player.Standard do
  def screen_name(%{global_name: global_name, username: username}) do
    @for.screen_name(global_name, username)
  end

  def screen_name_and_words(player), do: @for.screen_name_and_words(player)

  def discord_id(%{id: id}), do: id
  def game_id(%{id: id}), do: id
  def words(%{words: words}), do: List.wrap(words)
end
