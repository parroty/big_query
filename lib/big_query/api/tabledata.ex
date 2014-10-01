defmodule BigQuery.API.Tabledata do
  import BigQuery.API.Base

  def insert_all(dataset_id, table_id, rows) do
    params = %{
      "kind": "bigquery#tableDataInsertAllRequest",
      "rows": rows
    }

    url_for("projects/#{project_id}/datasets/#{dataset_id}/tables/#{table_id}/insertAll") |> post(params) |> fetch_body
  end

  def list_data(dataset_id, table_id, start_index \\ 0, max_results \\ 100) do
    params = %{
      "maxResults": max_results,
      "startIndex": start_index
    }

    body = url_for("projects/#{project_id}/datasets/#{dataset_id}/tables/#{table_id}/data") |> get(params) |> fetch_body
    parse_query_result(body["rows"])
  end
end