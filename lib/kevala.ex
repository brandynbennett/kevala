defmodule Kevala do
  @moduledoc """
  Documentation for `Kevala`.
  """
  alias Kevala.Boundary.EmployeeImporter

  def dedupe_employee_csv(csv_stream, strategy) do
    EmployeeImporter.remove_duplicates(csv_stream, strategy)
  end

  def dedupe_employee_csv(csv_stream) do
    EmployeeImporter.remove_duplicates(csv_stream)
  end
end
