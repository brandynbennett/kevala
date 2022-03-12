defmodule Kevala.Boundary.EmployeeImporterTest do
  use ExUnit.Case, async: true

  alias Kevala.Boundary.EmployeeImporter
  alias Kevala.Core.Employee

  test "remove_duplicates/2 ignores problem-free CSV" do
    csv =
      stream_csv(
        ~s("First Name","Last Name","Email","Phone"\n"Marge","Simpson","marge@simpsons.com","999-999-9999")
      )

    assert EmployeeImporter.remove_duplicates(csv) == [
             {:ok,
              %{
                "First Name" => "Marge",
                "Last Name" => "Simpson",
                "Email" => "marge@simpsons.com",
                "Phone" => "999-999-9999"
              }}
           ]
  end

  defp stream_csv(csv) do
    {:ok, stream} = StringIO.open(csv)
    stream |> IO.binstream(:line)
  end
end
