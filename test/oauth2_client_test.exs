defmodule OAuth2ClientTest do
  use ExUnit.Case

  test "initialization of client from parameters" do
    c = OAuth2Client.configure(
      id: "sample_client_id",
      secret: "sample_secret",
      site: "https://accounts.google.com/"
    )

    assert String.contains?(c.authorize_url, "accounts.google.com/o/oauth2/auth")
    assert String.contains?(c.authorize_url, "client_id=sample_client_id")
    assert String.contains?(c.authorize_url, "client_secret=sample_secret")
  end

  test "initialization of client from templates" do
    url = OAuth2Client.fetch_authorize_url(
      id: "sample_client_id",
      secret: "sample_secret",
      authorize_url: "https://github.com/login/auth_xxx",
      token_url:     "https://github.com/login/token_xxx"
    )

    assert String.contains?(c.authorize_url, "github.com/login/auth_xxx")
    assert String.contains?(c.authorize_url, "client_id=sample_client_id")
    assert String.contains?(c.authorize_url, "client_secret=sample_secret")
  end

  test "authentication with code" do
    token = OAuthClient.fetch_token(
      code: "code",
      scope: "https://www.googleapis.com/auth/userinfo.email"
    )

    assert token.value != nil
  end

  test "authentication with token string" do
    token = OAuthClient.load_token("sample_token")
    assert token.value != "sample_token"
  end

  test "calling api using token" do
    token = OAuthClient.load_token("sample_token")

    response = OAuthClient.get(token, "http://localhost:3000")
    assert response.body != nil
  end

end
