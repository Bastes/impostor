defmodule Impostor.Game.Player do
  @enforce_keys [:id, :global_name, :username]
  defstruct [:id, :global_name, :username, :version]

  def new(%{id: _, global_name: _, username: _} = data) do
    struct(__MODULE__, data)
  end

  def screen_name(%__MODULE__{global_name: global_name, username: username, version: version}) do
    make_screen_name(global_name, username, version)
  end

  defp make_screen_name(global_name, username, version \\ nil)

  defp make_screen_name(global_name, username, nil) do
    "#{global_name} (@#{username})"
  end

  defp make_screen_name(global_name, username, version) do
    make_screen_name(global_name, username <> " - #{version}")
  end
end
