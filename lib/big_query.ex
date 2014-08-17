defmodule BigQuery do
  defdelegate projects, to: BigQuery.API.Base
  defdelegate datasets(project), to: BigQuery.API.Base
  defdelegate jobs(project), to: BigQuery.API.Base

  defdelegate query(project, query),          to: BigQuery.API.Base
  defdelegate query(project, query, options), to: BigQuery.API.Base

  defmodule OAuth2ExAdapter do
    def client do
      scopes = ["https://www.googleapis.com/auth/userinfo.email",
               "https://www.googleapis.com/auth/userinfo.profile",
               "https://www.googleapis.com/auth/bigquery"]

      OAuth2Ex.create(
        id:            System.get_env("GOOGLE_API_CLIENT_ID"),
        secret:        System.get_env("GOOGLE_API_CLIENT_SECRET"),
        authorize_url: OAuth2Ex.Site.Google.authorize_url,
        token_url:     OAuth2Ex.Site.Google.token_url,
        scope:         Enum.join(scopes, " "),
        callback_url:  "http://localhost:4000"
      )
    end

    def token_file_path do
      System.user_home <> "/oauth2ex.google.token"
    end
  end

  def configure do
    OAuth2Ex.Token.Manager.configure(OAuth2ExAdapter, port: 4000)
  end

  def run do
    dispatch("google/login")
  end

  def request_token(code) do
    dispatch("google/callback?code=#{code}")
  end

  def network do
    networks = :simple_oauth2.predefined_networks
    callback_uri = "http://localhost:#{BigQuery.TokenListener.port}"
    scope = ["https://www.googleapis.com/auth/userinfo.email",
             "https://www.googleapis.com/auth/userinfo.profile",
             "https://www.googleapis.com/auth/bigquery"]

    :simple_oauth2.customize_networks(networks,
      [{"google", [{:client_id, client_id}, {:client_secret, client_secret},
                   {:callback_uri, callback_uri}, {:scope, Enum.join(scope, " ")}]}]
    )
  end

  defp client_id, do: System.get_env("GOOGLE_API_CLIENT_ID")
  defp client_secret, do: System.get_env("GOOGLE_API_CLIENT_SECRET")

  def dispatch(request) do
    case :simple_oauth2.dispatcher(request, "", network) do
      {:redirect, where} ->
        :simple_oauth2.gather_url_get(where) |> authenticate
      {:send_html, html} ->
        IO.inspect {:send_html, html}
      {:ok, auth_data} ->
        access_token = auth_data[:access_token]
        BigQuery.TokenStorage.save(access_token)
        :ok
      {:error, class, reason} ->
        IO.inspect {:error, class, reason}
    end
  end

  def authenticate(url) do
    BigQuery.TokenListener.start
    case open_by_browser(url) do
      :ok ->
        IO.puts ""
      :error ->
        IO.puts "Open the browser and visit the following link to authenticate."
        IO.puts url
    end
    # BigQuery.TokenListener.stop
  end

  defp open_by_browser(url) do
    try do
      {_output, exit_status} = System.cmd("open", [url])
      if exit_status == 0 do
        :ok
      else
        :error
      end
    rescue
      _ -> :error
    end
  end
end
