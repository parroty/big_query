defmodule BigQuery do
  defdelegate projects,                       to: BigQuery.API.Base
  defdelegate datasets(project),              to: BigQuery.API.Base
  defdelegate jobs(project),                  to: BigQuery.API.Base
  defdelegate query(project, query),          to: BigQuery.API.Base
  defdelegate query(project, query, options), to: BigQuery.API.Base

  defmodule OAuth2ExAdapter do
    use OAuth2Ex.Adapter

    def config do
      scopes = [ "https://www.googleapis.com/auth/userinfo.email",
                 "https://www.googleapis.com/auth/userinfo.profile",
                 "https://www.googleapis.com/auth/bigquery" ]

      OAuth2Ex.config(
        id:            System.get_env("GOOGLE_API_CLIENT_ID"),
        secret:        System.get_env("GOOGLE_API_CLIENT_SECRET"),
        authorize_url: OAuth2Ex.Site.Google.authorize_url,
        token_url:     OAuth2Ex.Site.Google.token_url,
        scope:         Enum.join(scopes, " "),
        callback_url:  "http://localhost:4000"
      )
    end

    def token_store_path do
      System.user_home <> "/oauth2ex.google.token"
    end
  end

  def configure do
    {:ok, msg} = OAuth2Ex.Token.Manager.configure(OAuth2ExAdapter, port: 4000)
    IO.puts msg
  end
end
