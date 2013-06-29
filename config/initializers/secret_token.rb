# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# By keeping the Rails 3 secret_token in place, Rails 4 auto upgrades people to secret_key_base
# via: http://blog.envylabs.com/post/41711428227/rails-4-security-for-session-cookies
Reading::Application.config.secret_token = '***REMOVED***'
Reading::Application.config.secret_key_base = '***REMOVED***'
