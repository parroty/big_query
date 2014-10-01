defmodule BigQuery.API.Base do
  use OAuth2Ex.Client

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
  Returns the target project_id for the BigQuery API.
  """
  def project_id, do: System.get_env("GOOGLE_BIG_QUERY_PROJECT_ID")

  def url_for(path) do
    "https://www.googleapis.com/bigquery/v2/#{path}"
  end

  def get_request(url) do
    url_for(url) |> get |> fetch_body
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

  def fetch_body(response) do
    if response.status_code < 200 or response.status_code > 299 do
      raise "Error response was returned from server. status_code: #{response.status_code}, body: #{inspect response.body}"
    else
      response.body
    end
  end
end