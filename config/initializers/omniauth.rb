Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'saMngnlSaaIapiznEqqw', '***REMOVED***'
  provider :facebook, '241046329250415', '***REMOVED***', {:scope => 'email, offline_access'}
end
