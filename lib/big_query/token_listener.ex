defmodule BigQuery.TokenListener do
  @moduledoc """
  Provides webserver listener for retrieving access token.
  """

  def start do
    Application.ensure_all_started(:cowboy)

    dispatch = :cowboy_router.compile([
      {:_,
        [{"/", BigQuery.TokenHandler, []}]
      }
    ])

    :cowboy.start_http(
      listner_name, 100,
      [{:port, port}], [{:env, [{:dispatch, dispatch}]}]
    )
  end

  def stop do
    :cowboy.stop_listener(listner_name)
  end

  def port do
    System.get_env("BIGQUERY_TOKEN_LISTNER_PORT") || 50800
  end

  defp listner_name do
    "bigquery_token_listener"
  end
end

