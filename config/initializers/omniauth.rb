Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'saMngnlSaaIapiznEqqw', '17tgkJvgwwdKplVqSfCHKTwsOjbaMuCW4Rxe3rrDkA'
  provider :facebook, '241046329250415', 'dedc9c174b5f712fe29bde26df8f8cdf', {:scope => 'email, offline_access'}
end
