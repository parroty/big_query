defmodule OAuth2ClientTest do
  use ExUnit.Case

  def client do
    OAuth2Client.create(
      id: "sample_client_id",
      secret: "sample_secret",
      authorize_url: OAuth2Client.Site.Google.authorize_url,
      token_url: OAuth2Client.Site.Google.token_url,
      scope: OAuth2Client.Site.Google.scope,
      callback_url: "http://localhost:3000/oauth2callback"
    )
  end

  test "initialization of client for pre-defined site" do
    url = OAuth2Client.fetch_authorize_url(client)

    assert String.contains?(url, "accounts.google.com/o/oauth2/auth")
    assert String.contains?(url, "client_id=sample_client_id")
    assert !String.contains?(url, "client_secret=sample_secret")
  end

  test "authentication with code" do
    token = OAuth2Client.fetch_token(client, "sample_code")
    assert %OAuth2Client.Token{} == token
  end

  test "save token to file" do
    token = %OAuth2Client.Token{
      access_token: "sample_access_token",
      expires_in: 3600,
      refresh_token: "sample_refresh_token",
      token_type: "Bearer"
    }

    file_name = "test/fixture/save_token.json"

    File.rm(file_name)
    OAuth2Client.Token.save_to_file(token, file_name)
    assert File.exists?(file_name) == true
  end

  test "load token from file" do
    file_name = "test/fixture/load_token.json"
    token = OAuth2Client.Token.load_from_file(file_name)

    assert token.access_token == "sample_access_token"
    assert token.expires_in == 3600
    assert token.refresh_token == "sample_refresh_token"
    assert token.token_type ==  "Bearer"
  end
end
