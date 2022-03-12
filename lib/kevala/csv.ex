defmodule Kevala.CSV do
  @moduledoc """
  Module for working with raw csv data
  """
  def decode(stream, options \\ []) do
    CSV.decode(stream, options)
  end

  def encode(list, options \\ []) do
    CSV.encode(list, options)
  end
end
