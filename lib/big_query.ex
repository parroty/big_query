defmodule BigQuery do
  # defdelegate projects,                       to: BigQuery.API.Base
  # defdelegate datasets(project),              to: BigQuery.API.Base
  # defdelegate jobs(project),                  to: BigQuery.API.Base
  # defdelegate query(project, query),          to: BigQuery.API.Base
  # defdelegate query(project, query, options), to: BigQuery.API.Base

  # initialize client from the specified parameters
  # def create(params) do

  # end

  @project_id System.get_env("GOOGLE_BIG_QUERY_PROJECT_ID")

  defmodule Client do
    @moduledoc """
    Client configuration for specifying required parameters
    for accessing OAuth 2.0 server.
    """

    use OAuth2Ex.Client

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
  end

  @doc """
  Retrieve the OAuth token from the server, and store to the file
  in the specified token_store path.
  """
  def browse_and_retrieve do
    Client.browse_and_retrieve!(receiver_port: 4000)
  end

  @doc """
  Refresh the OAuth access_token from the refresh_token, as
  Google's access token has expiration time.
  """
  def refresh_token, do: Client.refresh_token

  def project_id do
    @project_id
  end

  @doc """
  List the projects by calling Google BigQuery API - project list.
  API: https://developers.google.com/bigquery/docs/reference/v2/#Projects
  """
  def projects do
    response = OAuth2Ex.HTTP.get(Client.token, "https://www.googleapis.com/bigquery/v2/projects")
    response.body |> JSEX.decode!
  end

  def datasets do
    response = OAuth2Ex.HTTP.get(Client.token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets")
    response.body |> JSEX.decode!
  end

  def dataset(dataset_id) do
    response = OAuth2Ex.HTTP.get(Client.token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}")
    response.body |> JSEX.decode!
  end

  def tables(dataset_id) do
    response = OAuth2Ex.HTTP.get(Client.token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}/tables")
    response.body |> JSEX.decode!
  end

  def jobs(stateFilter \\ "running") do
    parsed_params = parse_query_params([{"stateFilter", stateFilter}])
    response = OAuth2Ex.HTTP.get(Client.token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/jobs?#{parsed_params}")
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

    response = OAuth2Ex.HTTP.post(Client.token, "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/queries", body, headers)
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
