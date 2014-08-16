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

  # test "accessing with token" do
  #   token = OAuth2Client.token_from_file("json_file")
  # end

  # test "authentication with token string" do
  #   token = OAuthClient.load_token("sample_token")
  #   assert token.value != "sample_token"
  # end

  # test "calling api using token" do
  #   token = OAuthClient.load_token("sample_token")

  #   response = OAuthClient.get(token, "http://localhost:3000")
  #   assert response.body != nil
  # end

end
