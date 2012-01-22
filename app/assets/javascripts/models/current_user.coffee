window.current_user = new User window.current_user

auths =
  twitter: new Provider
  facebook: new Provider

auths[auth.provider][auth.uid] = Authorization::factory auth for auth in window.authorizations
window.current_user.authorizations = auths
