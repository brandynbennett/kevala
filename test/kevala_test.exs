defmodule KevalaTest do
  use ExUnit.Case
  doctest Kevala

  test "greets the world" do
    assert Kevala.hello() == :world
  end
end
