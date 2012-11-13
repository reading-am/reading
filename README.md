Dude, where's my web app?

## Prerequisites

The following items must be installed and running:

* [Postgres](http://www.postgresql.org/)  
  `brew install postgresql`
* [Redis](http://redis.io/)  
  `brew install redis`
* [Slanger](https://github.com/stevegraham/slanger)
  *Note: Bundler will not install Slanger*  
  `gem install slanger`

## Environmental Variables

The app expects the following environmental variables to be set:

```bash
# Used to secure staging.reading.am
READING_AUTH_BASIC_USER
READING_AUTH_BASIC_PASS

# Amazon Web Services
READING_S3_KEY
READING_S3_SECRET

# Slanger Credentials
READING_SLANGER_KEY
READING_SLANGER_SECRET

# Facebook Oauth
READING_FACEBOOK_KEY
READING_FACEBOOK_SECRET

# Tumblr Oauth
READING_TUMBLR_KEY
READING_TUMBLR_SECRET

# 37 Signals Oauth
READING_SIGNALS37_KEY
READING_SIGNALS37_SECRET

# Twitter Oauth
READING_TWITTER_KEY
READING_TWITTER_SECRET

# Readability Oauth
READING_READABILITY_KEY
READING_READABILITY_SECRET
# Readability Content API
READING_READABILITY_TOKEN

# Instapaper Oauth
READING_INSTAPAPER_KEY
READING_INSTAPAPER_SECRET

# Evernote Oauth
READING_EVERNOTE_KEY
READING_EVERNOTE_SECRET

# Pocket / Readitlater Oauth
READING_POCKET_KEY
```

## Starting the app

We're using [Foreman](https://github.com/ddollar/foreman) for
process management so starting the app is as easy as running:

`foreman start`

...with one caveat. Slanger [doesn't seem to play well with Foreman](https://github.com/stevegraham/slanger/issues/77)
and needs to be started on its own using:

`slanger --app_key $READING_SLANGER_KEY --secret
$READING_SLANGER_SECRET`

## Testing

For Javascript, run:

`rake konacha:serve`

And visit:

`http://0.0.0.0:3500`

## Grant Admin Access
enter the following script in the rails console:
```ruby
u = User.find_by_username("someUsername")
u.roles << :admin
u.save!
```

