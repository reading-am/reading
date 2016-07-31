class TweetJob < ApplicationJob
  def perform(token, secret, tweet)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_KEY']
      config.consumer_secret =  ENV['TWITTER_SECRET']
      config.access_token = token
      config.access_token_secret = secret
    end
    client.update tweet
  end
end
