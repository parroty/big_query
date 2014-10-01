defmodule BigQuery.API.Tables do
  import BigQuery.API.Base

  def tables(dataset_id) do
    get_request("projects/#{project_id}/datasets/#{dataset_id}/tables")
  end

  def create_table(dataset_id, table_id, fields) do
    params = %{
      "kind": "bigquery#table",
      "tableReference": %{
        "projectId": project_id,
        "datasetId": dataset_id,
        "tableId": table_id
      },
      "schema": %{
        "fields": fields
      },
    }

    url_for("projects/#{project_id}/datasets/#{dataset_id}/tables") |> post(params) |> fetch_body
  end

  def delete_table(dataset_id, table_id) do
    url_for("projects/#{project_id}/datasets/#{dataset_id}/tables/#{table_id}") |> delete |> fetch_body
  end
end
