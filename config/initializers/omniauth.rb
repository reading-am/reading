Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, TWITTER_KEY, TWITTER_SECRET
  provider :facebook, FACEBOOK_KEY, FACEBOOK_SECRET, {:scope => 'email, offline_access'}
  provider :instapaper, INSTAPAPER_KEY, INSTAPAPER_SECRET
  provider :tumblr, TUMBLR_KEY, TUMBLR_SECRET
  provider "37signals", SIGNALS37_KEY, SIGNALS37_SECRET
end
