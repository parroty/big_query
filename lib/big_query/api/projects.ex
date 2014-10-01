defmodule BigQuery.API.Projects do
  import BigQuery.API.Base

  @doc """
  List the projects by calling Google BigQuery API - project list.
  API: https://developers.google.com/bigquery/docs/reference/v2/#Projects
  """
  def projects do
    body = get_request("projects")
    body["projects"]
  end
end
