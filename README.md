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

