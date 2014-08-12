defmodule BigQuery.TokenHandler do
  @moduledoc """
  Provides webserver handler for retrieving access token.
  """

  @success_message "Successfully authorized and token is retrieved."
  @failure_message "Authorization failed, and couldn't retrieve token."

  def init({_any, :http}, req, []) do
    {:ok, req, :undefined}
  end

  def handle(req, state) do
    {token, req} = :cowboy_req.qs_val("code", req)

    message = case token do
      "" ->
        @failure_message
      _  ->
        BigQuery.TokenStorage.save(token)
        @success_message
    end

    {:ok, req} = :cowboy_req.reply(200, [], message, req)
    {:ok, req, state}
  end

  def terminate(_reason, _request, _state) do
    :ok
  end
end
