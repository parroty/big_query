defmodule BigQuery.TokenHandler do
  @moduledoc """
  Provides handler for cowboy
  """

  def init({_any, :http}, req, []) do
    {:ok, req, :undefined}
  end

  def handle(req, state) do
    {:ok, req} = :cowboy_req.reply(200, [], "Hello World", req)
    {:ok, req, state}
  end

  def terminate(_reason, _request, _state) do
    :ok
  end
end
