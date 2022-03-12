defmodule Kevala.CSVTest do
  use ExUnit.Case, async: true

  test "decode/2 decodes a csv" do
    csv = stream_csv(~s("foo","bar"\n"baz","qux"))

    assert Kevala.CSV.decode(csv) |> Enum.to_list() == [
             {:ok, ["foo", "bar"]},
             {:ok, ["baz", "qux"]}
           ]
  end

  test "decode/2 accepts options" do
    csv = stream_csv(~s("foo","bar"\n"baz","qux"))

    assert Kevala.CSV.decode(csv, headers: true) |> Enum.to_list() ==
             [
               {:ok, %{"foo" => "baz", "bar" => "qux"}}
             ]
  end

  test "decode/2 shows errors" do
    csv = stream_csv(~s("\"foo","bar"\n"baz","qux"))

    assert Kevala.CSV.decode(csv) |> Enum.to_list() == [
             {:error, "Stray quote on line 1 near \"\""},
             {:ok, ["baz", "qux"]}
           ]
  end

  test "decode/2 puts duplicate columns into list" do
    csv = stream_csv(~s("foo","foo"\n"baz","qux"))

    assert Kevala.CSV.decode(csv, headers: true) |> Enum.to_list() ==
             [ok: %{"foo" => ["baz", "qux"]}]
  end

  defp stream_csv(csv) do
    {:ok, stream} = StringIO.open(csv)
    stream |> IO.binstream(:line)
  end
end
