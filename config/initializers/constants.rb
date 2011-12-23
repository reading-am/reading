SHORT_DOMAIN = 'ing.am'

if Rails.env == 'production'
  DOMAIN = 'reading.am'

  FACEBOOK_KEY = '241046329250415'
  FACEBOOK_SECRET = 'dedc9c174b5f712fe29bde26df8f8cdf'

  SIGNALS37_KEY = '870ff838037a62a7058c0fc93f4cb14632626b0f'
  SIGNALS37_SECRET = '6a2741bc2e998b3e07de412ac8504437dd3ea430'
else
  DOMAIN = Rails.env == 'staging' ? 'staging.reading.am' : '0.0.0.0:3000'
  # DOMAIN = 'reading.dev'
  FACEBOOK_KEY = '115933145182597'
  FACEBOOK_SECRET = 'da0fac5ca6afbe272f51e297d3380dce'

  SIGNALS37_KEY = '0d2eb24337e813014d81c35eb5fac0425293a9e9'
  SIGNALS37_SECRET = '27f7b8f3dcaabff9b2bf556aa4d9144c2c34eed5'
end

TWITTER_KEY = 'saMngnlSaaIapiznEqqw'
TWITTER_SECRET = '17tgkJvgwwdKplVqSfCHKTwsOjbaMuCW4Rxe3rrDkA'
