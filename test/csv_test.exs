defmodule Kevala.CSVTest do
  use ExUnit.Case, async: true

  test "decode/2 decodes a csv" do
    csv = ~s("foo","bar"\n"baz","qux")
    {:ok, stream} = StringIO.open(csv)

    assert stream |> IO.binstream(:line) |> Kevala.CSV.decode() |> Enum.to_list() == [
             {:ok, ["foo", "bar"]},
             {:ok, ["baz", "qux"]}
           ]
  end

  test "decode/2 accepts options" do
    csv = ~s("foo","bar"\n"baz","qux")
    {:ok, stream} = StringIO.open(csv)

    assert stream |> IO.binstream(:line) |> Kevala.CSV.decode(headers: true) |> Enum.to_list() ==
             [
               {:ok, %{"foo" => "baz", "bar" => "qux"}}
             ]
  end

  test "decode/2 shows errors" do
    csv = ~s("\"foo","bar"\n"baz","qux")
    {:ok, stream} = StringIO.open(csv)

    assert stream |> IO.binstream(:line) |> Kevala.CSV.decode() |> Enum.to_list() == [
             {:error, "Stray quote on line 1 near \"\""},
             {:ok, ["baz", "qux"]}
           ]
  end

  test "decode/2 puts duplicate columns into list" do
    csv = ~s("foo","foo"\n"baz","qux")
    {:ok, stream} = StringIO.open(csv)

    assert stream |> IO.binstream(:line) |> Kevala.CSV.decode(headers: true) |> Enum.to_list() ==
             [ok: %{"foo" => ["baz", "qux"]}]
  end
end
