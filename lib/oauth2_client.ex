defmodule OAuth2Client do
  def configure(params) do
    # raise error if required parameters are missing


    c = OAuth2Client.configure(
      id: "sample_client_id",
      secret: "sample_secret",
      site: "https://accounts.google.com/"
    )

  end
end

defmodule OAuth2Client.Site do
  def sites do
    %{
      "https://accounts.google.com" => [
        authorize_url: "https://accounts.google.com/o/oauth2/auth",
        token_url:     "https://accounts.google.com/o/oauth2/token"
      ],

      "https://github.com" =>[
        authorize_url: "https://github.com/login/oauth/authorize",
        token_url:     "https://github.com/login/oauth/access_token"
      ]
    }
end