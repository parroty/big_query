defmodule BigQuery.API.Jobs do
  import BigQuery.API.Base

  def query(query_string, dataset_id) do
    params = %{
      "kind": "bigquery#queryRequest",
      "query": query_string,
      "defaultDataset": %{
        "datasetId": dataset_id,
        "projectId": project_id
      }
    }

    body = url_for("projects/#{project_id}/queries") |> post(params) |> fetch_body
    parse_query_result(body["rows"])
  end

  def jobs(stateFilter \\ "running") do
    params = [stateFilter: stateFilter]
    url_for("projects/#{project_id}/jobs") |> get(params) |> fetch_body
  end
end