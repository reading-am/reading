define [
  "app/models/user"
  "app/models/authorizations/authorization"
  "app/models/providers/twitter"
  "app/models/providers/facebook"
  "app/models/providers/tumblr"
  "app/models/providers/instapaper"
  "app/models/providers/readability"
  "app/models/providers/evernote"
  "app/models/providers/pocket"
  "app/models/providers/flattr"
  "app/models/providers/slack"
  "app/models/authorizations/twitter"
  "app/models/authorizations/facebook"
  "app/models/authorizations/tumblr"
  "app/models/authorizations/instapaper"
  "app/models/authorizations/readability"
  "app/models/authorizations/evernote"
  "app/models/authorizations/pocket"
  "app/models/authorizations/flattr"
  "app/models/authorizations/slack"
  "app/collections/users" # needed from within models/user
], (User, Authorization, TwitterProv, FacebookProv, TumblrProv, InstapaperProv, ReadabilityProv, EvernoteProv, PocketProv, FlattrProv, SlackProv) ->

  if window.current_user_seed?
    User::current = new User window.current_user_seed
    window.current_user_seed = null
  else
    User::current = new User

  auths =
    twitter:    new TwitterProv
    facebook:   new FacebookProv
    tumblr:     new TumblrProv
    instapaper: new InstapaperProv
    readability:new ReadabilityProv
    evernote:   new EvernoteProv
    pocket:     new PocketProv
    flattr:     new FlattrProv
    slack:      new SlackProv

  if window.authorizations_seed?
    auths[auth.provider].set(auth.uid, Authorization::factory(auth)) for auth in window.authorizations_seed
    window.authorizations_seed = null

  User::current.set "authorizations", auths

  return User
