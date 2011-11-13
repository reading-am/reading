if Rails.env == 'production'
  DOMAIN = 'reading.am'

  FACEBOOK_KEY = '241046329250415'
  FACEBOOK_SECRET = '***REMOVED***'
else
  DOMAIN = '0.0.0.0:3000'

  FACEBOOK_KEY = '115933145182597'
  FACEBOOK_SECRET = '***REMOVED***'
end

TWITTER_KEY = 'saMngnlSaaIapiznEqqw'
TWITTER_SECRET = '***REMOVED***'
