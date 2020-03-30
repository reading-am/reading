# via: https://github.com/bundler/bundler/issues/4978#issuecomment-272248627
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

source 'http://rubygems.org'
ruby '~> 2.5.0'

#################
# Core Services #
#################
gem 'dotenv-rails', groups: [:development, :test]
gem 'rails', '5.0.7.2'
gem 'sinatra', github: 'sinatra/sinatra', require: nil # for sidekiq web UI
gem 'rack-protection' # required by sinatra >= 2
gem 'rails-observers', github: 'rails/rails-observers'
gem 'foreman'
gem 'rack-cors', require: 'rack/cors'
gem 'mysql2', '< 0.5' # version required by Rails 5
gem 'dalli' # Memcached
gem 'elasticsearch-model'
gem 'rails_12factor', group: [:staging, :production] # needed by Heroku

#############
# Core Libs #
#############
gem 'escape_utils' # fast string escaping lib used by Github
gem 'curb' # CURL bindings
gem 'nokogiri' # HTML / XML parsing
gem 'loofah' # for escaping html tags. Also in Rails core but needed independently
gem 'addressable' # URI parsing
gem 'oj' # fast JSON parser
gem 'typhoeus' # HTTP request gem recommended by koala
gem 'base58'
gem 'jbuilder' # json templates
gem 'versionist' # api versioning

#####################
# Ruby Conveniences #
#####################
gem 'bitmask_attributes', github: 'joelmoss/bitmask_attributes'
gem 'nilify_blanks'
gem 'paperclip' # file attachments
gem 'browser' # browser detection
gem 'text'
gem 'mime-types'

##############
# Monitoring #
##############
gem 'rollbar'

########
# Auth #
########
gem 'devise'
gem 'oauth'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-37signals'
gem 'omniauth-instapaper'
gem 'omniauth-tumblr'
gem 'omniauth-readability', github: '29decibel/omniauth-readability'
gem 'omniauth-evernote'
gem 'omniauth-pocket'
gem 'omniauth-slack'
gem 'doorkeeper'

####################
# Async Processing #
####################
gem 'sidekiq'
gem 'sidekiq-limit_fetch'

#####################
# External Services #
#####################
gem 'memcachier' # modifies Dalli to work with Heroku Memcachier add-on
gem 'aws-sdk'
gem 'hipchat'
gem 'pusher'
gem 'crack' # required by the hipchat gem
gem 'twitter'
gem 'koala', github: 'arsduo/koala' # facebook
gem 'instapaper', github: 'spagalloco/instapaper'
gem 'tumblr-ruby', github: 'weheartit/tumblr', require: 'tumblr'
gem 'readit', github: '29decibel/readit'
gem 'evernote-thrift'
gem 'ruby-thumbor'
gem 'slack-ruby-client'

#################
# Frontend HTML #
#################
gem 'twitter-bootstrap-rails', '2.2.8'
gem 'twitter_bootstrap_form_for', github: 'leppert/twitter_bootstrap_form_for'
gem 'premailer-rails'
gem 'twitter-text' # for comment parsing
gem "musterb", github: 'leppert/musterb'
gem 'tuml', github: 'leppert/tuml'

###############
# Frontend JS #
###############
gem 'requirejs-rails'
gem 'rails-backbone', github: 'thegillis/backbone-rails', branch: 'upgrade-backbone-1.3.3'
gem 'jquery-rails'

############
# Sitemaps #
############
# See: https://github.com/kjvarga/sitemap_generator/wiki/Generate-Sitemaps-on-read-only-filesystems-like-Heroku
gem 'sitemap_generator'
gem 'fog'

##########
# Assets #
##########
gem 'sprockets-rails', '2.3.2' # Prevents "Asset was not declared to be precompiled in production" for current version of requirejs-rails. So also: https://github.com/rails/sprockets-rails/issues/297
gem 'less-rails'
gem 'therubyracer' # Required by less-rails
gem 'coffee-rails'
gem 'uglifier' # NOTE JS minification happens in requirejs-rails and is configured in requirejs.yml

group :development do
  gem 'puma' # server
  gem 'puma-heroku' # default puma config as recommended by heroku
  gem 'rack-mini-profiler'
  gem 'bullet'
  gem 'ruby-growl' # used by bullet
  gem 'pry'
  gem 'pry-doc'
  gem 'progress_bar'
  gem 'better_errors'
  gem 'binding_of_caller' # for better_errors
  gem 'irbtools', require: false
  gem 'terminal-notifier', require: false # or else irbtools will complain
  gem 'meta_request' # for RailsPanel
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
  gem 'letter_opener'
  gem "capistrano", "~> 3.10", require: false
  gem "capistrano-rails", "~> 1.4", require: false
end

group :development, :test do
  gem 'teaspoon-mocha'
  gem 'tapout'
  gem 'rspec-rails'
  gem 'watchr'
  gem 'pry-byebug'
  gem 'capybara'
  gem 'selenium-webdriver'
  # gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'rspec_junit_formatter', '0.2.2' # needed by circleci
  gem 'spring-commands-rspec'
  gem 'json-schema'
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'elasticsearch-extensions'
end
