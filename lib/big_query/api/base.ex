defmodule BigQuery.API.Base do
  @basePath "https://www.googleapis.com/bigquery/v2/"

  def request(url) do
    headers = [{"Authorization", "OAuth #{get_token}"}]
    body = HTTPoison.get(url, headers).body
    JSEX.decode!(body)
  end

  def get_token do
    BigQuery.TokenStorage.load
  end

  def datasets(project) do
    url = url_for("projects/#{project}/datasets")
    json = request(url)
    json["datasets"]
  end

  def projects do
    url = url_for("projects")
    json = request(url)
    json["projects"]
  end

  def url_for(path) do
    @basePath <> path
  end
end