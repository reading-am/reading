[![build status badge](https://circleci.com/gh/leppert/reading.png?circle-token=3cdfe76f6db89bae21a76c6fb3ad2744a5c77ac4)](https://circleci.com/gh/leppert/reading)

## Prerequisites

The following items must be installed and running:

* [Postgres](http://www.postgresql.org/)  
  `brew install postgresql`
* [Redis](http://redis.io/)  
  `brew install redis`
* [Slanger](https://github.com/stevegraham/slanger)
  *Note: Bundler will not install Slanger*
* [Mailcatcher](http://mailcatcher.me)
  Note: This is run by foreman. Don't start manually.  
  `gem install mailcatcher`

## Environmental Variables

The app expects the environmental variables defined in `.env.example` to
be set. Copy this file to `.env` and set the appropriate values.

## Starting the app

We're using [Foreman](https://github.com/ddollar/foreman) for
process management so starting the app is as easy as running:

`foreman start -f Procfile.dev`

...with one caveat. Slanger [doesn't seem to play well with Foreman](https://github.com/stevegraham/slanger/issues/77)
and needs to be started on its own using:

`slanger --app_key $SLANGER_KEY --secret
$SLANGER_SECRET --webhook_url
http://0.0.0.0:3000/pusher/existence`

## Testing

### Ruby

Test are run continually by [Watchr](https://github.com/mynyml/watchr)
when each spec file is modified. Output is listed by [Foreman](https://github.com/ddollar/foreman)
under the process named `testruby`.

### Javascript

Tests are run through [Mocha](http://visionmedia.github.com/mocha/)
via [Teaspoon](https://github.com/modeset/teaspoon) by visiting
<http://0.0.0.0:3000/teaspoon> in your browser.

### Mail

Mail sent in the dev environment is intercepted by Mailcatcher
and can be read at <http://127.0.0.1:1080>

## Grant Admin Access
enter the following script in the rails console:
```ruby
u = User.find_by_username!("someUsername")
u.roles << :admin
u.save!
```
