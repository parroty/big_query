defmodule BigQuery.TokenStorage do
  @moduledoc """
  Provides file storage functionality for saving and loading tokens.
  """

  @default_path "bigquery.token"

  def save(token) do
    File.write!(@default_path, token)
  end

  def load do
    case File.read(@default_path) do
      {:ok, token} ->
        token
      {:error, reason} ->
        IO.puts "Failed to load token. reason: #{reason}"
        nil
    end
  end
end