defmodule BigQuery do
  # defdelegate projects,                       to: BigQuery.API.Base
  # defdelegate datasets(project),              to: BigQuery.API.Base
  # defdelegate jobs(project),                  to: BigQuery.API.Base
  # defdelegate query(project, query),          to: BigQuery.API.Base
  # defdelegate query(project, query, options), to: BigQuery.API.Base
  use OAuth2Ex.Client

  @project_id System.get_env("GOOGLE_BIG_QUERY_PROJECT_ID")

  @doc """
  Returns the target project_id for the BigQuery API.
  """
  def project_id, do: @project_id

  @doc """
  Client configuration setting for specifying required parameters
  for accessing OAuth 2.0 server.
  """
  def config do
    OAuth2Ex.config(
      id:            System.get_env("GOOGLE_API_CLIENT_ID"),
      secret:        System.get_env("GOOGLE_API_CLIENT_SECRET"),
      authorize_url: "https://accounts.google.com/o/oauth2/auth",
      token_url:     "https://accounts.google.com/o/oauth2/token",
      scope:         "https://www.googleapis.com/auth/bigquery",
      callback_url:  "http://localhost:4000",
      token_store:   %OAuth2Ex.FileStorage{
                       file_path: System.user_home <> "/oauth2ex.google.token"}
    )
  end

  @doc """
  List the projects by calling Google BigQuery API - project list.
  API: https://developers.google.com/bigquery/docs/reference/v2/#Projects
  """
  def projects do
    # response = http_get("https://www.googleapis.com/bigquery/v2/projects")
    response = OAuth2Ex.HTTP.get(token, "https://www.googleapis.com/bigquery/v2/projects")
    response.body |> JSEX.decode!
  end

  def datasets do
    response = OAuth2Ex.HTTP.get(token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets")
    response.body |> JSEX.decode!
  end

  def dataset(dataset_id) do
    response = OAuth2Ex.HTTP.get(token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}")
    response.body |> JSEX.decode!
  end

  def tables(dataset_id) do
    response = OAuth2Ex.HTTP.get(token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}/tables")
    response.body |> JSEX.decode!
  end

  def jobs(stateFilter \\ "running") do
    parsed_params = parse_query_params([{"stateFilter", stateFilter}])
    response = OAuth2Ex.HTTP.get(token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/jobs?#{parsed_params}")
    response.body |> JSEX.decode!
  end

  def query do
    headers = [{"Content-Type", "application/json"}]
    body = %{
      "kind": "bigquery#queryRequest",
      "query": "SELECT kind, name, population FROM [sample_dataset.sample_table] LIMIT 1000",
      "defaultDataset": %{
        "datasetId": "sample_dataset",
        "projectId": "ktsquall"
      }
    } |> JSEX.encode!

    response = OAuth2Ex.HTTP.post(token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/queries", body, headers)
    body = response.body |> JSEX.decode!
    parse_query_result(body["rows"])
  end

  def parse_query_params(params) do
    params |> Enum.map(fn({k,v}) -> "#{k}=#{v}" end)
           |> Enum.join("&")
  end

  def parse_query_result(rows) do
    rows |> Enum.map(fn(data) -> parse_row(data["f"]) end)
  end

  def parse_row(row) do
    row |> Enum.map(fn(data) -> data["v"] end)
  end
end
