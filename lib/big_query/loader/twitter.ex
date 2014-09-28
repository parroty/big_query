defmodule BigQuery.Loader.Twitter do
  def dataset_id, do: "sample_dataset"
  def table_id, do: "twitter"

  def start do
    ExTwitter.configure(
       consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
       consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
       access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
       access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
    )
  end

  def load_stream(keyword) do
    pid = spawn(fn ->
      stream = ExTwitter.stream_filter(track: "keyword")
      for tweet <- stream do
        IO.puts tweet.text
      end
    end)
  end

  def load_sample do
    tweets = [
      ExTwitter.show(512695470469021698),
      ExTwitter.show(512695295843368960)
    ]

    tweets |> Enum.map(&parse_tweet/1)
           |> insert
  end

  defp insert(tweets) do
    BigQuery.insert_all(dataset_id, table_id, tweets)
  end

  def create_table do
    fields = [
      %{ "name": "id", "type": "STRING" },
      %{ "name": "text", "type": "STRING" },
    ]

    BigQuery.create_table(dataset_id, table_id, fields)
  end

  def delete_table do
    BigQuery.delete_table(dataset_id, table_id)
  end

  def parse_tweet(tweet) do
    %{
      "insertID": to_string(tweet.id),
      "json": %{
        "id": to_string(tweet.id),
        "text": tweet.text
      }
    }
  end
end