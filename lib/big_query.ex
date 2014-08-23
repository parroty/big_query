defmodule BigQuery do
  # defdelegate projects,                       to: BigQuery.API.Base
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
        callback_url:  "http://localhost:4000",
        token_store:   System.user_home <> "/oauth2ex.google.token"
      )
    end
  end

  def configure do
    {:ok, msg} = OAuth2Ex.Token.Manager.configure(OAuth2ExAdapter, port: 4000)
    IO.puts msg
  end

  def projects do
    url = "https://www.googleapis.com/bigquery/v2/projects"
    OAuth2Ex.Request.get(OAuth2ExAdapter, url).body
  end
end

defmodule GitHub do
  defmodule OAuth2ExAdapter do
    use OAuth2Ex.Adapter

    def config do
      OAuth2Ex.config(
        id:            System.get_env("GITHUB_API_CLIENT_ID"),
        secret:        System.get_env("GITHUB_API_CLIENT_SECRET"),
        authorize_url: OAuth2Ex.Site.GitHub.authorize_url,
        token_url:     OAuth2Ex.Site.GitHub.token_url,
        scope:         ["public_repo"],
        callback_url:  "http://localhost:4000",
        token_store:   System.user_home <> "/oauth2ex.github.token",
        header_prefix: "token" # Authorization: token OAUTH-TOKEN
      )
    end
  end

  def configure do
    {:ok, msg} = OAuth2Ex.Token.Manager.configure(OAuth2ExAdapter, port: 4000)
    IO.puts msg
  end

  def get_authorization do
    url = "https://api.github.com/authorizations"
    OAuth2Ex.Request.get(OAuth2ExAdapter, url).body
  end
end

defmodule Dropbox do
  defmodule OAuth2ExAdapter do
    use OAuth2Ex.Adapter

    def config do
      OAuth2Ex.config(
        id:            System.get_env("DROPBOX_API_CLIENT_ID"),
        secret:        System.get_env("DROPBOX_API_CLIENT_SECRET"),
        authorize_url: OAuth2Ex.Site.Dropbox.authorize_url,
        token_url:     OAuth2Ex.Site.Dropbox.token_url,
        scope:         [],
        callback_url:  "http://localhost:4000",
        token_store:   System.user_home <> "/oauth2ex.dropbox.token",
        header_prefix: "Bearer" # Authorization: Bearer <access token>
      )
    end
  end

  def configure do
    {:ok, msg} = OAuth2Ex.Token.Manager.configure(OAuth2ExAdapter, port: 4000)
    IO.puts msg
  end

  def get_account do
    url = "https://api.dropbox.com/1/account/info"
    OAuth2Ex.Request.get(OAuth2ExAdapter, url).body
  end
end
