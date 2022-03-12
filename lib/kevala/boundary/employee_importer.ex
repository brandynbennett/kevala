defmodule Kevala.Boundary.EmployeeImporter do
  def remove_duplicates(csv, duplicate_detection_strategy \\ :email_or_phone) do
    Kevala.CSV.decode(csv, headers: true) |> Enum.to_list()
  end
end
