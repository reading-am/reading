Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter,    ENV['READING_TWITTER_KEY'],     ENV['READING_TWITTER_SECRET']
  provider :facebook,   ENV['READING_FACEBOOK_KEY'],    ENV['READING_FACEBOOK_SECRET'], {:scope => 'email, offline_access'}
  provider :instapaper, ENV['READING_INSTAPAPER_KEY'],  ENV['READING_INSTAPAPER_SECRET']
  provider :tumblr,     ENV['READING_TUMBLR_KEY'],      ENV['READING_TUMBLR_SECRET']
  provider :readability,ENV['READING_READABILITY_KEY'], ENV['READING_READABILITY_SECRET']
  provider "37signals", ENV['READING_SIGNALS37_KEY'],   ENV['READING_SIGNALS37_SECRET']
end
