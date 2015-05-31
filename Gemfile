source 'http://rubygems.org'
ruby '2.1.4'

#################
# Core Services #
#################
gem 'dotenv-rails', groups: [:development, :test]
gem 'rails', '4.2.1'
gem 'rails-observers'
gem 'foreman'
gem 'puma' # server
gem 'rack-cors', require: 'rack/cors'
gem 'pg' # PostgresSQL
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
gem 'rack-mini-profiler'
gem 'newrelic_rpm'

########
# Auth #
########
gem 'devise'
gem 'oauth'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '1.4.0' # had trouble with v1.4.1
gem 'omniauth-37signals'
gem 'omniauth-instapaper'
gem 'omniauth-tumblr'
gem 'omniauth-readability', github: '29decibel/omniauth-readability'
gem 'omniauth-evernote'
gem 'omniauth-pocket'
gem 'omniauth-flattr'
gem 'omniauth-http-basic', github: 'leppert/omniauth-http-basic' #required by omniauth-kippt
gem 'omniauth-kippt', github: 'leppert/omniauth-kippt'
gem 'doorkeeper'

####################
# Async Processing #
####################
gem 'sucker_punch'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons' # for delayed_job
gem "workless" # boots up workers on Heroku when needed

#####################
# External Services #
#####################
gem 'memcachier' # modifies Dalli to work with Heroku Memcachier add-on
gem 'aws-sdk'
gem 'hipchat'
gem 'tinder', github: 'skirchmeier/tinder' # campfire. Only using this branch to bypass JSON dependency
gem 'pusher'
gem 'crack' # required by the hipchat gem
gem 'twitter'
gem 'koala', github: 'arsduo/koala' # facebook
gem 'instapaper', github: 'spagalloco/instapaper'
gem 'tumblr-ruby', github: 'weheartit/tumblr', require: 'tumblr'
gem 'readit', github: '29decibel/readit'
gem 'evernote-thrift'
gem 'kippt', github: 'leppert/kippt'
gem 'flattr', github: 'smgt/flattr'
gem 'ruby-thumbor'

#################
# Frontend HTML #
#################
gem 'will_paginate', github: 'mislav/will_paginate'
gem 'twitter-bootstrap-rails'
gem 'bootstrap-will_paginate'
gem 'twitter_bootstrap_form_for', github: 'leppert/twitter_bootstrap_form_for'
gem 'premailer-rails'
gem 'twitter-text' # for comment parsing
gem "musterb", github: 'leppert/musterb'
gem 'tuml', github: 'leppert/tuml'

###############
# Frontend JS #
###############
gem 'requirejs-rails'
gem 'rails-backbone'
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
gem 'less-rails', '2.3.3' # Can be upgraded when twitter_bootstrap_rails is upgraded. See: https://github.com/metaskills/less-rails/issues/71
gem 'therubyracer' # Required by less-rails
gem 'coffee-rails'
gem 'uglifier' # NOTE JS minification happens in requirejs-rails and is configured in requirejs.yml

group :development do
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
end

group :development, :test do
  gem 'teaspoon'
  gem 'tapout'
  gem 'rspec-rails'
  gem 'watchr'
  gem 'pry-byebug'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'spring-commands-rspec'
  gem 'json-schema'
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'elasticsearch-extensions'
end
