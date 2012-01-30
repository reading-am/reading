SHORT_DOMAIN = 'ing.am'

if Rails.env == 'production'
  DOMAIN = 'reading.am'

  FACEBOOK_KEY = '241046329250415'
  FACEBOOK_SECRET = '***REMOVED***'

  SIGNALS37_KEY = '***REMOVED***'
  SIGNALS37_SECRET = '***REMOVED***'
else
  DOMAIN = Rails.env == 'staging' ? 'staging.reading.am' : '0.0.0.0:3000'
  # DOMAIN = 'reading.dev'
  FACEBOOK_KEY = '115933145182597'
  FACEBOOK_SECRET = '***REMOVED***'

  SIGNALS37_KEY = '***REMOVED***'
  SIGNALS37_SECRET = '***REMOVED***'
end

TWITTER_KEY = 'saMngnlSaaIapiznEqqw'
TWITTER_SECRET = '***REMOVED***'

BOOKMARKLET_VERSION = '1.0.1'
