source 'http://rubygems.org'
ruby '1.9.3'

gem 'unicorn' # server
gem 'rack-cors', :require => 'rack/cors'

gem 'rails', '3.2.12'
group :assets do
  gem 'sass-rails'
  gem 'less-rails'
  # Required by less-rails. Not sure why it's not included by the gem. 0.11.0 has trouble with libv8
  # https://github.com/cowboyd/therubyracer/issues/215
  gem 'therubyracer', '~> 0.10.2'
  gem 'coffee-rails'
  gem 'uglifier' # NOTE JS minification happens in requirejs-rails and is configured in requirejs.yml
end

gem 'requirejs-rails', :git => 'git://github.com/leppert/requirejs-rails.git'
gem 'rails-backbone'
gem 'jquery-rails'

gem 'pg' # PostgresSQL
gem 'dalli' # Memcache
gem 'sunspot_rails' # Solr

gem 'devise'
gem 'oauth', :git => 'git://github.com/oauth/oauth-ruby.git'
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

gem 'hipchat'
gem 'curb', '~> 0.8.0'
gem 'nokogiri'
gem 'addressable'
gem 'base58'
gem 'will_paginate'
gem 'tinder' # campfire
gem 'pusher', '0.10.0' # 0.11 installs gem signature 0.1.6 which throws 404s
gem 'crack' # required by the hipchat gem
gem 'yajl-ruby' # JSON parser recommended by twitter gem
gem 'twitter'
gem 'typhoeus' # HTTP request gem recommended by koala
gem 'koala' # facebook

gem 'delayed_job', "3.0.1"
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons' # for delayed_job
gem 'girl_friday'
# gem 'hirefire' # has to be AFTER delayed_job
gem 'hirefireapp' # has to be AFTER delayed_job

gem 'nilify_blanks'
gem 'validate_email'
gem 'twitter-bootstrap-rails', '2.1.4' # there's a LESS compile issue with 2.1.6
gem 'bootstrap-will_paginate'
gem 'twitter_bootstrap_form_for', :git => 'git://github.com/zzip/twitter_bootstrap_form_for.git'
gem 'aws-sdk'
gem 'paperclip'
gem 'browser'
gem 'sanitize'
gem 'yajl-ruby', require: 'yajl' # fast JSON parser
gem 'instapaper', :git => 'git://github.com/leppert/instapaper.git'
gem 'tumblr-ruby', require: 'tumblr'
gem 'readit', :git => 'git://github.com/29decibel/readit.git'
gem 'evernote-thrift'
gem 'thrift' # added to force 0.9.0 install to fix evernote encoding issues
gem 'kippt', :git => 'git://github.com/leppert/kippt.git'
gem 'flattr'
gem 'bitmask_attributes'
gem 'premailer-rails3', :git => 'git://github.com/Sija/premailer-rails3.git'
gem 'twitter-text' # for comment parsing

# for sitemaps. See: https://github.com/kjvarga/sitemap_generator/wiki/Generate-Sitemaps-on-read-only-filesystems-like-Heroku
gem 'sitemap_generator'
gem 'carrierwave'
gem 'fog'

group :development do
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
