defmodule OAuth2Client.Client do
  defstruct id: nil, secret: nil, authorize_url: nil, token_url: nil, scope: nil, callback_url: nil, response_type: nil
end

defmodule OAuth2Client.Token do
  defstruct access_token: nil, expires_in: nil, refresh_token: nil, token_type: nil
end

defmodule OAuth2Client.Site do
  defmodule Google do
    def authorize_url do
      "https://accounts.google.com/o/oauth2/auth"
    end

    def token_url do
      "https://accounts.google.com/o/oauth2/token"
    end

    def scope do
       "https://www.googleapis.com/auth/userinfo.email"
     end
  end

  defmodule GitHub do
    def authorize_url do
      "https://github.com/login/oauth/authorize"
    end

    def token_url do
      "https://github.com/login/oauth/access_token"
    end

    def scope do
      ""
    end
  end
end

defmodule OAuth2Client.Requester do
  use HTTPoison.Base
end

defmodule OAuth2Client do
  def test1 do
    OAuth2Client.create(
      id: System.get_env("GOOGLE_API_CLIENT_ID"),
      secret: System.get_env("GOOGLE_API_CLIENT_SECRET"),
      authorize_url: OAuth2Client.Site.Google.authorize_url,
      token_url: OAuth2Client.Site.Google.token_url,
      scope: OAuth2Client.Site.Google.scope,
      callback_url: "http://localhost:3000/oauth2callback"
    )
  end

  def test2 do
    OAuth2Client.fetch_authorize_url(test1)
  end

  def test3(code) do
    OAuth2Client.fetch_token(test1, code)
  end

  # TODO: raise error if required parameters are missing
  def create(params) do
    %OAuth2Client.Client{
      id: params[:id],
      secret: params[:secret],
      authorize_url: params[:authorize_url],
      token_url: params[:token_url],
      scope: params[:scope],
      callback_url: params[:callback_url],
      response_type: params[:response_type] || "code"
    }
  end

  def fetch_authorize_url(client) do
    query_params = [
      client_id:     client.id,
      redirect_uri:  client.callback_url,
      response_type: client.response_type,
      scope:         client.scope
    ] |> join

    client.authorize_url <> "?" <> query_params
  end

  def fetch_token(client, code) do
    query_params = [
      client_id: client.id,
      client_secret: client.secret,
      redirect_uri: client.callback_url,
      code: code,
      grant_type: "authorization_code",
    ] |> join

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    HTTPoison.post(client.token_url, [query_params], headers).body
      |> JSEX.decode!
      |> parse_token
  end

  defp parse_token(json) do
    %OAuth2Client.Token{
      access_token: json["access_token"],
      expires_in: json["expires_in"],
      refresh_token: json["refresh_token"],
      token_type: json["token_type"]
    }
  end

  defp join(params) do
    params |> Enum.map(fn({k,v}) -> "#{k}=#{v}" end)
           |> Enum.join("&")
  end
end
