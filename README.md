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
* [Mailcatcher](http://mailcatcher.me)
  Note: This is run by foreman. Don't start manually.  
  `gem install mailcatcher`

## Environmental Variables

The app expects the environmental variables defined in `.env.example` to
be set. Copy this file to `.env` and set the appropriate values.

## Starting the app

We're using [Foreman](https://github.com/ddollar/foreman) for
process management so starting the app is as easy as running:

`foreman start`

...with one caveat. Slanger [doesn't seem to play well with Foreman](https://github.com/stevegraham/slanger/issues/77)
and needs to be started on its own using:

`slanger --app_key $READING_SLANGER_KEY --secret
$READING_SLANGER_SECRET`

## Testing

### Ruby

Test are run continually by [Watchr](https://github.com/mynyml/watchr)
when each spec file is modified. Output is listed by [Foreman](https://github.com/ddollar/foreman)
under the process named `testruby`.

### Javascript

Tests are run through [Mocha](http://visionmedia.github.com/mocha/)
via [Konacha](https://github.com/jfirebaugh/konacha) by visiting
<http://0.0.0.0:3500> in your browser.

### Mail

Mail sent in the dev environment is intercepted by Mailcatcher
and can be read at <http://127.0.0.1:1080>

## Grant Admin Access
enter the following script in the rails console:
```ruby
u = User.find_by_username("someUsername")
u.roles << :admin
u.save!
```
