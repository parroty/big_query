defmodule BigQuery.API.Base do
  @basePath "https://www.googleapis.com/bigquery/v2/"

  # def get_request(url) do
  #   headers = [{"Authorization", "OAuth #{get_token}"}]
  #   body = HTTPoison.get(url, headers).body
  #   case JSEX.decode!(body) do
  #     %{"error" => error} ->
  #       raise %BigQuery.Error{message: "Error occurred in the API call: #{inspect error}"}
  #     json -> json
  #   end
  # end

  # def post_request(url, request_body) do
  #   headers = [{"Authorization", "OAuth #{get_token}"}, {"Content-Type", "application/json"}]
  #   body = HTTPoison.post(url, request_body, headers).body
  #   case JSEX.decode!(body) do
  #     %{"error" => error} ->
  #       raise %BigQuery.Error{message: "Error occurred in the API call: #{inspect error}"}
  #     json -> json
  #   end
  # end

  def get(url) do
    body = OAuth2Ex.Request.get(BigQuery.OAuth2ExAdapter.token, url).body

    case JSEX.decode!(body) do
      %{"error" => error} ->
        raise %BigQuery.Error{message: "Error occurred in the API call: #{inspect error}"}
      json -> json
    end
  end

  def projects do
    url = url_for("projects")
    json = get(url)
    json["projects"]
  end

  # def datasets(project) do
  #   url = url_for("projects/#{project}/datasets")
  #   json = get_request(url)
  #   json["datasets"]
  # end

  # def jobs(project) do
  #   url = url_for("projects/#{project}/jobs")
  #   json = get_request(url)
  # end

  # def sample_query do
  #   "SELECT * FROM [sample_dataset.sample_table] LIMIT 1000"
  # end

  # def query(project, query, options \\ []) do
  #   body = %{"kind" => "bigquery#queryget_Request", "query" => query} |> JSEX.encode!
  #   url = url_for("projects/#{project}/queries")
  #   post_request(url, body)
  # end

  def url_for(path) do
    @basePath <> path
  end
end