source 'http://rubygems.org'
ruby '2.0.0'

#################
# Core Services #
#################
gem 'rails', '4.0.0'
gem 'unicorn' # server
gem 'rack-cors', :require => 'rack/cors'
gem 'pg' # PostgresSQL
gem 'dalli', :github => 'mperham/dalli' # Memcached
gem 'sunspot_rails' # Solr

#############
# Core Libs #
#############
gem 'escape_utils' # fast string escaping lib used by Github
gem 'curb', '~> 0.8.0' # CURL bindings
gem 'nokogiri' # HTML / XML parsing
gem 'addressable' # URI parsing
gem 'oj' # fast JSON parser
gem 'typhoeus' # HTTP request gem recommended by koala
gem 'base58'
gem 'mechanize' # web crawler

#####################
# Ruby Conveniences #
#####################
#gem 'identity_cache'
#gem 'bitmask_attributes'
gem 'nilify_blanks'
gem 'validate_email'
gem 'paperclip' # file attachments
gem 'browser' # browser detection
gem 'sanitize' # HTML sanitizer
gem 'ruby-oembed'
gem 'text'

##############
# Monitoring #
##############
gem 'rack-mini-profiler'
gem 'newrelic_rpm'

########
# Auth #
########
gem 'devise', '~> 3.0.0.rc'
gem 'oauth'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '1.4.0' # had trouble with v1.4.1
gem 'omniauth-37signals', :github => 'leppert/omniauth-37signals'
gem 'omniauth-instapaper'
gem 'omniauth-tumblr'
gem 'omniauth-readability'
gem 'omniauth-evernote'
gem 'omniauth-pocket'
gem 'omniauth-flattr'
gem 'omniauth-http-basic', :github => 'leppert/omniauth-http-basic' #required by omniauth-kippt
gem 'omniauth-kippt', :github => 'leppert/omniauth-kippt'

####################
# Async Processing #
####################
gem 'girl_friday'
gem 'delayed_job', :github => 'collectiveidea/delayed_job'
gem 'delayed_job_active_record', :github => 'collectiveidea/delayed_job_active_record'
#gem 'delayed_job_web'
gem 'daemons' # for delayed_job

#####################
# External Services #
#####################
gem 'memcachier' # modifies Dalli to work with Heroku Memcachier add-on
gem 'hirefireapp' # has to be AFTER delayed_job
gem 'aws-sdk'
gem 'hipchat'
gem 'tinder' # campfire
gem 'pusher'
gem 'crack' # required by the hipchat gem
gem 'twitter'
gem 'koala' # facebook
gem 'instapaper', :github => 'leppert/instapaper'
gem 'tumblr-ruby', github: 'weheartit/tumblr', require: 'tumblr'
gem 'readit', :github => '29decibel/readit'
gem 'evernote-thrift'
gem 'kippt', :github => 'leppert/kippt'
gem 'flattr'

#################
# Frontend HTML #
#################
gem 'will_paginate'
gem 'twitter-bootstrap-rails'
gem 'bootstrap-will_paginate'
#gem 'twitter_bootstrap_form_for', :github => 'zzip/twitter_bootstrap_form_for'
gem 'premailer-rails'
gem 'twitter-text' # for comment parsing
gem "musterb", :github => 'leppert/musterb'
gem 'tuml', :github => 'leppert/tuml'

###############
# Frontend JS #
###############
gem 'requirejs-rails', :github => 'jwhitley/requirejs-rails'
gem 'rails-backbone'
gem 'jquery-rails'

############
# Sitemaps #
############
# See: https://github.com/kjvarga/sitemap_generator/wiki/Generate-Sitemaps-on-read-only-filesystems-like-Heroku
gem 'sitemap_generator'
gem 'carrierwave'
gem 'fog'

group :assets do
  gem 'less-rails'
  gem 'therubyracer' # Required by less-rails
  gem 'coffee-rails', github: 'rails/coffee-rails'
  gem 'uglifier' # NOTE JS minification happens in requirejs-rails and is configured in requirejs.yml
end

group :development do
  gem 'bullet'
  gem 'ruby-growl' # used by bullet
  gem 'debugger'
  gem 'sunspot_solr'
  gem 'progress_bar'
  gem 'better_errors'
  gem 'binding_of_caller' # for better_errors
  gem 'irbtools', :require => false
  gem 'terminal-notifier', :require => false # or else irbtools will complain
end

group :development, :test do
  #gem 'konacha', '~> 1.0'
  gem 'rspec-rails'
  #gem 'spork-rails'
  gem 'watchr'
end
