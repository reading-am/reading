class TweetJob
  include SuckerPunch::Job
  workers 4

  def perform token, secret, tweet
    Twitter::Client.new(oauth_token: token, oauth_token_secret: secret).update tweet rescue nil
  end

end
