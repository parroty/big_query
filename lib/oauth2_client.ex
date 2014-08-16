defmodule OAuth2Client.Client do
  defstruct id: nil, secret: nil, authorize_url: nil, token_url: nil, scope: nil, callback_url: nil, response_type: nil
end

#TODO: support expires at
defmodule OAuth2Client.Token do
  defstruct access_token: nil, expires_in: nil, refresh_token: nil, token_type: nil

  def load_from_file(file_name) do
    File.read!(file_name) |> JSEX.decode! |> merge_map(%OAuth2Client.Token{})
  end

  def save_to_file(token, file_name) do
    json = JSEX.encode!(token) |> JSEX.prettify!
    File.write!(file_name, json)
  end

  defp merge_map(json, struct) do
    keys = Map.keys(struct)
    Enum.reduce(keys, struct, fn(key, acc) ->
      atom_key = Atom.to_string(key)
      if atom_key != "__struct__" and Map.has_key?(json, atom_key) do
        Map.put(acc, key, Map.fetch!(json, atom_key))
      else
        acc
      end
    end)
  end
end

defmodule OAuth2Client.Site do
  defmodule Google do
    def authorize_url, do: "https://accounts.google.com/o/oauth2/auth"
    def token_url, do:     "https://accounts.google.com/o/oauth2/token"
    def scope, do:         "https://www.googleapis.com/auth/userinfo.email"
  end

  defmodule GitHub do
    def authorize_url, do: "https://github.com/login/oauth/authorize"
    def token_url, do:     "https://github.com/login/oauth/access_token"
    def scope, do:         ""
  end
end

defmodule OAuth2Client.Requester do
  def get(token, url, headers \\ [], options \\ []),         do: request(token, :get, url, "", headers, options)
  def put(token, url, body, headers \\ [], options \\ []),   do: request(token, :put, url, body, headers, options)
  def head(token ,url, headers \\ [], options \\ []),        do: request(token, :head, url, "", headers, options)
  def post(token, url, body, headers \\ [], options \\ []),  do: request(token, :post, url, body, headers, options)
  def patch(token, url, body, headers \\ [], options \\ []), do: request(token, :patch, url, body, headers, options)
  def delete(token, url, headers \\ [], options \\ []),      do: request(token, :delete, url, "", headers, options)
  def options(token, url, headers \\ [], options \\ []),     do: request(token, :options, url, "", headers, options)

  defp request(token, method, url, body, headers, options) do
    oauth_header = [{"Authorization", "OAuth #{token}"}]
    HTTPoison.request(method, url, body, headers ++ oauth_header, options)
  end
end

defmodule OAuth2Client do
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
