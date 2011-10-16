Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'saMngnlSaaIapiznEqqw', '17tgkJvgwwdKplVqSfCHKTwsOjbaMuCW4Rxe3rrDkA'
  if Rails.env == 'production'
    provider :facebook, '241046329250415', 'dedc9c174b5f712fe29bde26df8f8cdf', {:scope => 'email, offline_access'}
  else
    provider :facebook, '115933145182597', 'da0fac5ca6afbe272f51e297d3380dce', {:scope => 'email, offline_access'}
  end
end
