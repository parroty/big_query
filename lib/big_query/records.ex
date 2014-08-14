defmodule BigQuery.Records do

  defmodule Project do
    @moduledoc """
    https://developers.google.com/bigquery/docs/reference/v2/projects/list
    """

    defstruct kind: nil, id: nil, projectReference: nil,
              friendlyName: nil, totalItems: nil, numericId: nil
  end
end