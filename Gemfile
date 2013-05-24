source 'http://rubygems.org'
ruby '2.0.0'

#################
# Core Services #
#################
gem 'rails', :git => 'git://github.com/rails/rails.git', :branch => '3-2-stable' # switch back to gem version when 3.2.14 lands
gem 'unicorn' # server
gem 'rack-cors', :require => 'rack/cors'
gem 'pg' # PostgresSQL
gem 'dalli', :git => 'git://github.com/mperham/dalli.git' # Memcached
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
gem 'identity_cache'
gem 'bitmask_attributes'
gem 'nilify_blanks'
gem 'validate_email'
gem 'paperclip' # file attachments
gem 'browser' # browser detection
gem 'sanitize' # HTML sanitizer
gem 'ruby-oembed'

########
# Auth #
########
gem 'devise'
gem 'oauth'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '1.4.0' # had trouble with v1.4.1
gem 'omniauth-37signals', :git => 'git://github.com/leppert/omniauth-37signals.git'
gem 'omniauth-instapaper'
gem 'omniauth-tumblr'
gem 'omniauth-readability'
gem 'omniauth-evernote'
gem 'omniauth-pocket'
gem 'omniauth-flattr'
gem 'omniauth-http-basic', :git => 'git://github.com/leppert/omniauth-http-basic.git' #required by omniauth-kippt
gem 'omniauth-kippt', :git => 'git://github.com/leppert/omniauth-kippt.git'

####################
# Async Processing #
####################
gem 'girl_friday'
gem 'delayed_job', "3.0.1"
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons' # for delayed_job

#####################
# External Services #
#####################
gem 'memcachier' # modifies Dalli to work with Heroku Memcachier add-on
gem 'newrelic_rpm'
gem 'hirefireapp' # has to be AFTER delayed_job
gem 'aws-sdk'
gem 'hipchat'
gem 'tinder' # campfire
gem 'pusher', '0.10.0' # 0.11 installs gem signature 0.1.6 which throws 404s
gem 'crack' # required by the hipchat gem
gem 'twitter'
gem 'koala' # facebook
gem 'instapaper', :git => 'git://github.com/leppert/instapaper.git'
gem 'tumblr-ruby', require: 'tumblr'
gem 'readit', :git => 'git://github.com/29decibel/readit.git'
gem 'evernote-thrift'
gem 'kippt', :git => 'git://github.com/leppert/kippt.git'
gem 'flattr'

#################
# Frontend HTML #
#################
gem 'will_paginate'
gem 'twitter-bootstrap-rails', '2.1.4' # there's a LESS compile issue with 2.1.6
gem 'bootstrap-will_paginate'
gem 'twitter_bootstrap_form_for', :git => 'git://github.com/zzip/twitter_bootstrap_form_for.git'
gem 'premailer-rails'
gem 'twitter-text' # for comment parsing
gem "musterb", :git => 'git://github.com/leppert/musterb.git'

###############
# Frontend JS #
###############
gem 'requirejs-rails', :git => 'git://github.com/leppert/requirejs-rails.git', :ref => 'c4268ab2c0fd6f508efdf73214e75144b9fc4c09' # using an older ref because the new one balloons the precompile time, which takes forever on Heroku
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
  gem 'sass-rails'
  gem 'less-rails'
  # Required by less-rails. Not sure why it's not included by the gem. 0.11.0 has trouble with libv8
  # https://github.com/cowboyd/therubyracer/issues/215
  gem 'therubyracer', '~> 0.10.2'
  gem 'coffee-rails'
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
  gem 'konacha', '~> 1.0'
  gem 'rspec-rails'
  gem 'spork-rails'
  gem 'watchr'
end
