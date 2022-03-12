defmodule Kevala.Boundary.EmployeeImporter do
  @moduledoc """
  Import employee data from a CSV
  """

  @expected_headers ["First Name", "Last Name", "Phone", "Email"]

  def remove_duplicates(csv, _duplicate_detection_strategy \\ :email_or_phone) do
    with {:ok, data} <- decode(csv),
         :ok <- validate_headers(data) do
      to_csv(data)
    end
  end

  defp decode(csv) do
    try do
      {:ok, Kevala.CSV.decode(csv, headers: true) |> Enum.to_list()}
    rescue
      _error -> {:error, "CSV not parseable"}
    end
  end

  defp validate_headers(data) do
    with {:ok, row} <- first_valid_row(data),
         {:ok, headers} <- get_headers(row),
         :ok <- find_missing_headers(headers) do
      :ok
    end
  end

  defp first_valid_row(data) do
    row = Enum.find(data, &(elem(&1, 0) == :ok))
    if row, do: {:ok, elem(row, 1)}, else: {:error, "No valid rows"}
  end

  defp get_headers(row) do
    {:ok, Map.keys(row)}
  end

  defp find_missing_headers(headers) do
    difference = find_header_difference(headers)
    expected = lowercase_headers(@expected_headers) |> MapSet.new()
    headers = lowercase_headers(headers) |> MapSet.new()

    if MapSet.subset?(expected, headers) do
      :ok
    else
      {:error, "Headers `#{difference}` are required, but were not provided"}
    end
  end

  defp find_header_difference(headers) do
    expected = lowercase_headers(@expected_headers) |> MapSet.new()
    headers = lowercase_headers(headers) |> MapSet.new()

    MapSet.difference(expected, headers)
    |> Enum.to_list()
    |> capitalize_headers()
    |> Enum.join(",")
  end

  defp lowercase_headers(headers) do
    Enum.map(headers, &String.downcase(&1))
  end

  defp capitalize_headers(headers) do
    Enum.map(headers, fn header ->
      String.split(header, " ") |> Enum.map_join(" ", &String.capitalize(&1))
    end)
  end

  defp to_csv(data) do
    Enum.reduce(data, [@expected_headers], fn row, acc ->
      nil
    end)
  end
end
