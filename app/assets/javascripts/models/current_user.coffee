window.current_user = new User window.current_user

auths =
  twitter:[]
  facebook:[]

auths[auth.provider].push(Authorization::factory auth) for auth in window.authorizations
window.current_user.authorizations = auths
