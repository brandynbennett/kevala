defmodule Kevala.Boundary.EmployeeImporterTest do
  use ExUnit.Case, async: true

  alias Kevala.Boundary.EmployeeImporter
  alias Kevala.Core.Employee

  test "remove_duplicates/2 returns error if not parseable" do
    assert EmployeeImporter.remove_duplicates(:foo) == {:error, "CSV not parseable"}
  end

  test "remove_duplicates/2 returns error if missing columns" do
    csv = stream_csv(~s(First Name,Email\nMarge,marge@simpsons.com))

    assert EmployeeImporter.remove_duplicates(csv) ==
             {:error, "Headers `Last Name,Phone` are required, but were not provided"}
  end

  test "remove_duplicates/2 case-insensitive headers" do
    csv =
      stream_csv(
        ~s(first name,last name,email,phone\nMarge,Simpson,marge@simpsons.com,999-999-9999)
      )

    assert EmployeeImporter.remove_duplicates(csv) ==
             ~s(First Name,Last Name,Email,Phone\nMarge,Simpson,marge@simpsons.com,999-999-9999\n)
  end

  test "remove_duplicates/2 returns error if no valid rows" do
    csv = stream_csv(~s(First Name,Email\n\"Marge,marge@simpsons.com))

    assert EmployeeImporter.remove_duplicates(csv) ==
             {:error, "No valid rows"}
  end

  test "remove_duplicates/2 removes invalid rows" do
    csv =
      stream_csv(
        ~s(First Name,Last Name,Email,Phone\n) <>
          ~s(\"Marge,Simpson,marge@simpsons.com,999-999-9999\n) <>
          ~s(Homer,Simpson,homer@simpsons.com,888-191-2999)
      )

    assert EmployeeImporter.remove_duplicates(csv) ==
             ~s(First Name,Last Name,Email,Phone\nHomer,Simpson,homer@simpsons.com,888-191-2999\n)
  end

  test "remove_duplicates/2 ignores problem-free CSV" do
    csv =
      stream_csv(
        ~s(First Name,Last Name,Email,Phone\nMarge,Simpson,marge@simpsons.com,999-999-9999)
      )

    assert EmployeeImporter.remove_duplicates(csv) ==
             ~s(First Name,Last Name,Email,Phone\nMarge,Simpson,marge@simpsons.com,999-999-9999\n)
  end

  defp stream_csv(csv) do
    {:ok, stream} = StringIO.open(csv)
    stream |> IO.binstream(:line)
  end
end
