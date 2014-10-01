defmodule BigQuery.Loader.Twitter do
  def dataset_id, do: "sample_dataset"
  def table_id, do: "twitter"

  @chunk_size 50

  def start do
    ExTwitter.configure(
       consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
       consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
       access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
       access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
    )
  end

  def load_stream(keyword) do
    spawn(fn ->
      stream = ExTwitter.stream_filter(track: keyword) |> Stream.chunk(@chunk_size)
      for tweets <- stream do
        IO.puts "----------inserting #{@chunk_size} records----------"
        insert_tweets(Enum.reverse(tweets))
      end
    end)
  end

  def load_sample do
    tweets = [
      ExTwitter.show(512695470469021698),
      ExTwitter.show(512695295843368960)
    ]

    insert_tweets(tweets)
  end

  defp insert_tweets(tweets) do
    tweets
      |> Enum.map(&parse_tweet/1)
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