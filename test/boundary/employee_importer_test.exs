defmodule Kevala.Boundary.EmployeeImporterTest do
  use ExUnit.Case, async: true

  alias Kevala.Boundary.EmployeeImporter
  alias Kevala.Core.Employee

  test "remove_duplicates/2 returns error if not parseable" do
    assert EmployeeImporter.remove_duplicates(:foo) == {:error, "CSV not parseable"}
  end

  test "remove_duplicates/2 returns error if missing columns" do
    csv = stream_csv(~s("First Name","Email"\n"Marge","marge@simpsons.com"))

    assert EmployeeImporter.remove_duplicates(csv) ==
             {:error, "Headers Last Name,Phone are required, but were not provided"}
  end

  test "remove_duplicates/2 ignores problem-free CSV" do
    csv =
      stream_csv(
        ~s("First Name","Last Name","Email","Phone"\n"Marge","Simpson","marge@simpsons.com","999-999-9999")
      )

    assert EmployeeImporter.remove_duplicates(csv) ==
             ~s("First Name","Last Name","Email","Phone"\n"Marge","Simpson","marge@simpsons.com","999-999-9999")
  end

  defp stream_csv(csv) do
    {:ok, stream} = StringIO.open(csv)
    stream |> IO.binstream(:line)
  end
end
