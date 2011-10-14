source 'http://rubygems.org'

gem 'thin' # server

require 'uri/common'; ::URI.send :remove_const, :WFKV_ # tempfix per: http://stackoverflow.com/questions/7624661/rake-already-initialized-constant-warning
gem 'rails', '3.1.1'
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end
gem 'jquery-rails'

gem 'pg' # PostgresSQL
gem 'dalli' # Memcache
gem 'omniauth'
gem 'hipchat'
gem 'curb'
gem 'nokogiri'
gem 'addressable'
gem 'base58'
gem 'rufus-scheduler'
gem 'will_paginate'
gem 'tinder'
gem 'pusher', "~> 0.8.3"
gem 'em-http-request' # needed for async pusher calls
gem 'crack' # required by the hipchat gem
