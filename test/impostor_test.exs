defmodule ImpostorTest do
  use ExUnit.Case
  doctest Impostor

  test "greets the world" do
    assert Impostor.hello() == :world
  end
end
