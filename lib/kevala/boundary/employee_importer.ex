defmodule Kevala.Boundary.EmployeeImporter do
  @moduledoc """
  Import employee data from a CSV
  """

  @expected_headers ["First Name", "Last Name", "Email", "Phone"]

  def remove_duplicates(csv_stream, strategy \\ :email_or_phone) do
    with {:ok, csv_stream} <- decode(csv_stream),
         {:ok, csv_stream} <- remove_error_rows(csv_stream),
         :ok <- validate_headers(csv_stream),
         header_map <- header_map(csv_stream),
         {:ok, data} <- dedupe_rows(csv_stream, header_map, strategy),
         data <- sort(data, header_map) do
      to_csv(data, header_map)
    end
  end

  defp decode(csv_stream) do
    try do
      stream = Kevala.CSV.decode(csv_stream, headers: true) |> Enum.to_list() |> Stream.into([])
      {:ok, stream}
    rescue
      _error -> {:error, "CSV not parseable"}
    end
  end

  defp remove_error_rows(csv_stream) do
    stream =
      Stream.filter(csv_stream, &(elem(&1, 0) == :ok))
      |> Enum.map(&elem(&1, 1))

    {:ok, stream}
  end

  defp validate_headers(csv_stream) do
    with {:ok, row} <- first_valid_row(csv_stream),
         {:ok, headers} <- get_headers(row),
         :ok <- find_missing_headers(headers) do
      :ok
    end
  end

  defp first_valid_row(csv_stream) do
    row = Enum.at(csv_stream, 0)
    if row, do: {:ok, row}, else: {:error, "No valid rows"}
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
    Enum.map(headers, &capitalize_header/1)
  end

  defp capitalize_header(header) do
    String.split(header, " ") |> Enum.map_join(" ", &String.capitalize(&1))
  end

  defp dedupe_rows(csv_stream, header_map, :email_or_phone) do
    email_dedupe = dedupe_groups(csv_stream, header_map["Email"]) |> MapSet.new()
    phone_dedupe = dedupe_groups(csv_stream, header_map["Phone"]) |> MapSet.new()
    {:ok, MapSet.intersection(email_dedupe, phone_dedupe) |> Enum.to_list()}
  end

  defp dedupe_rows(csv_stream, header_map, :email) do
    header = header_map["Email"]
    {:ok, dedupe_groups(csv_stream, header)}
  end

  defp dedupe_rows(csv_stream, header_map, :phone) do
    header = header_map["Phone"]
    {:ok, dedupe_groups(csv_stream, header)}
  end

  defp dedupe_rows(_csv, _header_map, strategy) do
    {:error, "Cannot deduplicate by #{strategy}"}
  end

  defp dedupe_groups(csv_stream, header) do
    Enum.group_by(csv_stream, & &1[header])
    |> Enum.reduce([], fn {_key, rows}, acc ->
      [Enum.at(rows, 0) | acc]
    end)
  end

  defp sort(csv, header_map) do
    header = header_map["First Name"]
    Enum.sort_by(csv, & &1[header])
  end

  defp to_csv(csv_stream, header_map) do
    Enum.reduce(csv_stream, [@expected_headers], fn row, acc ->
      Enum.concat(acc, [row_to_csv(row, header_map)])
    end)
    |> Kevala.CSV.encode(delimiter: "\n")
    |> Enum.to_list()
    |> Enum.join("")
  end

  defp header_map(csv_stream) do
    {:ok, row} = first_valid_row(csv_stream)
    {:ok, headers} = get_headers(row)

    Enum.reduce(@expected_headers, %{}, fn expected_header, acc ->
      header = Enum.find(headers, fn header -> capitalize_header(header) == expected_header end)
      Map.put(acc, expected_header, header)
    end)
  end

  defp row_to_csv(row, header_map) do
    Enum.reduce(@expected_headers, [], fn expected_header, acc ->
      header = header_map[expected_header]
      Enum.concat(acc, [row[header]])
    end)
  end
end
