source 'http://rubygems.org'
ruby '1.9.3'

gem 'thin' # server
gem 'rack-cors', :require => 'rack/cors'

gem 'rails', '3.2.8'
group :assets do
  gem 'sass-rails'
  gem 'less-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'requirejs-rails', :git => 'git://github.com/leppert/requirejs-rails.git'
gem 'rails-backbone'
gem 'jquery-rails'

gem 'pg' # PostgresSQL
gem 'dalli' # Memcache

gem 'oauth', :git => 'git://github.com/oauth/oauth-ruby.git'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '1.4.0' # had trouble with v1.4.1
gem 'omniauth-37signals'
gem 'omniauth-instapaper'
gem 'omniauth-tumblr'
gem 'omniauth-readability'
gem 'omniauth-evernote'
gem 'omniauth-pocket', :path => '~/Desktop/projects/code/omniauth-pocket'
gem 'omniauth-http-basic', :git => 'git://github.com/leppert/omniauth-http-basic.git' #required by omniauth-kippt
gem 'omniauth-kippt', :git => 'git://github.com/leppert/omniauth-kippt.git'

gem 'hipchat'
gem 'curb', '~> 0.8.0'
gem 'nokogiri'
gem 'addressable'
gem 'base58'
gem 'will_paginate'
gem 'tinder' # campfire
gem 'pusher'
gem 'em-http-request' # needed for async pusher calls
gem 'crack' # required by the hipchat gem
gem 'yajl-ruby' # JSON parser recommended by twitter gem
gem 'twitter'
gem 'typhoeus' # HTTP request gem recommended by koala
gem 'koala' # facebook
gem 'sunspot_rails'
gem 'delayed_job', "3.0.1"
gem 'delayed_job_active_record'
gem 'daemons' # for delayed_job
# gem 'hirefire' # has to be AFTER delayed_job
gem 'hirefireapp' # has to be AFTER delayed_job
gem 'validate_email'
gem "twitter-bootstrap-rails", :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
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
gem 'evernote'
gem 'kippt', :git => 'git://github.com/leppert/kippt.git'
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
end

group :development, :test do
  gem 'konacha'
  gem 'rspec-rails'
  gem 'spork-rails'
  gem 'watchr'
end
