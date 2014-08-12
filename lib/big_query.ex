defmodule BigQuery do
  def run do
    dispatch("google/login")
  end

  def network do
    client_id     = System.get_env("GOOGLE_API_CLIENT_ID")
    client_secret = System.get_env("GOOGLE_API_CLIENT_SECRET")
    callback_uri  = "http://localhost"
    scope = "https://www.googleapis.com/auth/bigquery"

    :simple_oauth2.customize_networks(:simple_oauth2.predefined_networks(),
      [{"google", [{:client_id, client_id}, {:client_secret, client_secret}, {:callback_uri, callback_uri}, {:scope, scope}]}]
    )
  end

  def dispatch(request) do
    case :simple_oauth2.dispatcher(request, "", network) do
      {:redirect, where} ->
        :simple_oauth2.gather_url_get(where) |> authenticate
      {:send_html, html} ->
        IO.inspect {:send_html, html}
      {:error, class, reason} ->
        IO.inspect {:error, class, reason}
    end
  end

  def authenticate(url) do
    case System.cmd("open", url) do
      {:ok, _exit_status} ->
        IO.puts ""
      {:error, _reason} ->
        IO.puts "Open the browser and visit the following link to authenticate."
        IO.puts url
    end
  end
end
