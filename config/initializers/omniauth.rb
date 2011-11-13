Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, TWITTER_KEY, TWITTER_SECRET
  if Rails.env == 'production'
    provider :facebook, '241046329250415', '***REMOVED***', {:scope => 'email, offline_access'}
  else
    provider :facebook, '115933145182597', '***REMOVED***', {:scope => 'email, offline_access'}
  end
end
