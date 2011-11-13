if Rails.env == 'production'
  DOMAIN = 'reading.am'

  FACEBOOK_KEY = '241046329250415'
  FACEBOOK_SECRET = 'dedc9c174b5f712fe29bde26df8f8cdf'
else
  DOMAIN = '0.0.0.0:3000'

  FACEBOOK_KEY = '115933145182597'
  FACEBOOK_SECRET = 'da0fac5ca6afbe272f51e297d3380dce'
end

TWITTER_KEY = 'saMngnlSaaIapiznEqqw'
TWITTER_SECRET = '17tgkJvgwwdKplVqSfCHKTwsOjbaMuCW4Rxe3rrDkA'
