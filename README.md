[WIP] Elixir + BigQuery Sample
========

Sample application for accessing Google BigQuery using Elixir.

# Basic Usage
## Configure environment variables
- GOOGLE_API_CLIENT_ID
    - client_id which can be retrived from Google Developers Console.
- GOOGLE_API_CLIENT_SECRET
    - client_secret which can be retrived from Google Developers Console.
- GOOGLE_BIG_QUERY_PROJECT_ID
    - project id for accessing big query table.

## Open IEx
```Shell
> git clone http://github.com/parroty/big_query
> cd big_query
> mix deps.get
> iex -S mix
```

## Fetch Token
By default, token is stored in `~/oauth2ex.google.token`.

```Elixir
# Setup config parameters (retrive required parameters from OAuth 2.0 providers).
config = BigQuery.API.Base.config
# -> %OAuth2Ex.Config{authorize_url: "https://accounts.google.com/o/oauth2/auth"...

# Get authentication parameters.
IO.puts OAuth2Ex.get_authorize_url(config)
# -> https://accounts.google.com/o/oauth2/auth?client_id=1...
#    Open this url using browser and acquire code string.

# Acquire code from browser and a get access token using the code.
code = "xxx..."
token = OAuth2Ex.get_token(config, code)
# -> %OAuth2Ex.Token{access_token: "xxx.......",
#    expires_at: 1408467022, expires_in: 3600,
#    refresh_token: "yyy....",
#    token_type: "Bearer"}

# Save token to a file for later use.
OAuth2Ex.Token.save(token)
```

## Access BigQuery tables
```Elixir
# Counts Wikipedia page in sample dataset
> BigQuery.query("SELECT count(*) FROM [publicdata:samples.wikipedia]", "wikipedia")
# -> [["313797035"]]
```

# Twitter Loader Sample
An example to load tabledata from twitter stream.

## Configure environment variables
- TWITTER_CONSUMER_KEY
- TWITTER_CONSUMER_SECRET
- TWITTER_ACCESS_TOKEN
- TWITTER_ACCESS_SECRET

## Create dataset (pre-configuration)
Create dataset named `sample_dataset` in BigQuery management console.

## Create table and load data from twitter stream
```elixir

# Create table in the `sample_dataset`.
BigQuery.Loader.Twitter.create_table
# -> %{"etag" => ...
#  "schema" => %{"fields" => [%{"name" => "id", "type" => "STRING"},
#     %{"name" => "text", "type" => "STRING"}]},

# Configure twitter client module.
BigQuery.Loader.Twitter.start
# -> :ok

# Start loading stream which has keyword "apple".
pid = BigQuery.Loader.Twitter.load_stream("apple")
# -> #PID<0.191.0>
# -> Inserted 50 records.
# -> Inserted 50 records.
# -> Inserted 50 records.
# ...

# Check record count.
BigQuery.Loader.Twitter.count_records
# -> [["150"]]

# Stop loading stream.
BigQuery.Loader.Twitter.stop_stream(pid)
# -> :ok

# Delete the created table.
BigQuery.Loader.Twitter.delete_table
# -> ""

...
