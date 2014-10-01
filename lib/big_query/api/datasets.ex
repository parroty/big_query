defmodule BigQuery.API.Datasets do
  import BigQuery.API.Base

  def datasets do
    body = get_request("projects/#{project_id}/datasets")
    body["datasets"]
  end

  def dataset(dataset_id) do
    get_request("projects/#{project_id}/datasets/#{dataset_id}")
  end
end