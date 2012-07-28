reading.define [
  "app/models/user"
  "models/authorization"
  "models/twitter_prov"
  "models/facebook_prov"
  "models/tumblr_prov"
  "models/instapaper_prov"
  "models/readability_prov"
  "models/tssignals_prov"
  "models/twitter_auth"
  "models/facebook_auth"
  "models/tumblr_auth"
  "models/instapaper_auth"
  "models/readability_auth"
  "models/tssignals_auth"
  "app/collections/users" # needed from within models/user
], (User, Authorization, TwitterProv, FacebookProv, TumblrProv, InstapaperProv, ReadabilityProv, TssignalsProv) ->

  current_user = new User window.current_user_seed

  auths =
    twitter:    new TwitterProv
    facebook:   new FacebookProv
    tumblr:     new TumblrProv
    instapaper: new InstapaperProv
    readability:new ReadabilityProv
    tssignals:  new TssignalsProv

  auths[auth.provider][auth.uid] = Authorization::factory auth for auth in window.authorizations_seed
  current_user.set "authorizations", auths

  window.current_user_seed = window.authorizations_seed = null

  return current_user
