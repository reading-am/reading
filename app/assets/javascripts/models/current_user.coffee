window.current_user = new User window.current_user

auths =
  twitter: new TwitterProv
  facebook: new FacebookProv
  tumblr: new TumblrProv
  instapaper: new InstapaperProv
  readability: new ReadabilityProv

auths[auth.provider][auth.uid] = Authorization::factory auth for auth in window.authorizations
window.current_user.authorizations = auths
