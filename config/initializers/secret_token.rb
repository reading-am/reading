# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# By keeping the Rails 3 secret_token in place, Rails 4 auto upgrades people to secret_key_base
# via: http://blog.envylabs.com/post/41711428227/rails-4-security-for-session-cookies
Reading::Application.config.secret_token = '3a0fa968d1cc7548fa923141393e9d6d6ed8fe0fc8caff5642ebe68ebfaf8f204b67eaf795803f4bf4d22e25e12ff4ce1bf17a6e54289e575692ffddac726e01'
Reading::Application.config.secret_key_base = '58bc08f113c35a72485e9f749bb73307a145dcdeb5ec79aae162f5fb8b3836878206ee746c6236ab31fa9a07edf6ed8ecce8db6bf80df6dc9e213edd37b0f8da'
