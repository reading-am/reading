define [
  "app/models/user"
  "app/models/authorizations/authorization"
  "app/models/providers/twitter"
  "app/models/providers/facebook"
  "app/models/providers/tumblr"
  "app/models/providers/instapaper"
  "app/models/providers/readability"
  "app/models/providers/evernote"
  "app/models/providers/tssignals"
  "app/models/providers/kippt"
  "app/models/providers/pocket"
  "app/models/authorizations/twitter"
  "app/models/authorizations/facebook"
  "app/models/authorizations/tumblr"
  "app/models/authorizations/instapaper"
  "app/models/authorizations/readability"
  "app/models/authorizations/evernote"
  "app/models/authorizations/tssignals"
  "app/models/authorizations/kippt"
  "app/models/authorizations/pocket"
  "app/collections/users" # needed from within models/user
], (User, Authorization, TwitterProv, FacebookProv, TumblrProv, InstapaperProv, ReadabilityProv, EvernoteProv, TssignalsProv, KipptProv, PocketProv) ->

  current_user = new User window.current_user_seed

  auths =
    twitter:    new TwitterProv
    facebook:   new FacebookProv
    tumblr:     new TumblrProv
    instapaper: new InstapaperProv
    readability:new ReadabilityProv
    evernote:   new EvernoteProv
    tssignals:  new TssignalsProv
    kippt:      new KipptProv
    pocket:     new PocketProv

  auths[auth.provider][auth.uid] = Authorization::factory auth for auth in window.authorizations_seed
  current_user.set "authorizations", auths

  window.current_user_seed = window.authorizations_seed = null

  return current_user
