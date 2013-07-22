source 'http://rubygems.org'
ruby '2.0.0'

#################
# Core Services #
#################
gem 'rails', '4.0.0'
gem 'rails-observers'
gem 'unicorn' # server
gem 'rack-cors', require: 'rack/cors'
gem 'pg' # PostgresSQL
gem 'dalli' # Memcached
gem 'sunspot_rails', github: 'leppert/sunspot', branch: '2.0.0-rails4'
gem 'rails_12factor', group: :production # needed by Heroku

#############
# Core Libs #
#############
gem 'escape_utils' # fast string escaping lib used by Github
gem 'curb' # CURL bindings
gem 'nokogiri' # HTML / XML parsing
gem 'addressable' # URI parsing
gem 'oj' # fast JSON parser
gem 'typhoeus' # HTTP request gem recommended by koala
gem 'base58'
gem 'mechanize' # web crawler

#####################
# Ruby Conveniences #
#####################
gem 'bitmask_attributes', github: 'zlx/bitmask_attributes', branch: 'feature/support_rails_4'
gem 'nilify_blanks'
gem 'paperclip' # file attachments
gem 'browser' # browser detection
gem 'sanitize' # HTML sanitizer
gem 'ruby-oembed'
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

####################
# Async Processing #
####################
gem 'girl_friday'
gem 'delayed_job', '~> 4.0.0.beta2'
gem 'delayed_job_active_record', '~> 4.0.0.beta3'
gem 'delayed_job_web'
gem 'daemons' # for delayed_job

#####################
# External Services #
#####################
gem 'memcachier' # modifies Dalli to work with Heroku Memcachier add-on
gem 'hirefire-resource'
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

#################
# Frontend HTML #
#################
gem 'will_paginate', github: 'mislav/will_paginate'
gem 'twitter-bootstrap-rails'
gem 'bootstrap-will_paginate'
gem 'twitter_bootstrap_form_for', github: 'leppert/twitter_bootstrap_form_for'
gem 'premailer-rails', github: 'leppert/premailer-rails', branch: 'patch-1'
gem 'twitter-text' # for comment parsing
gem "musterb", github: 'leppert/musterb'
gem 'tuml', github: 'leppert/tuml'

###############
# Frontend JS #
###############
gem 'requirejs-rails', github: 'leppert/requirejs-rails', branch: 'rails4' # using an older ref because the new one balloons the precompile time, which takes forever on Heroku
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
gem 'less-rails'
gem 'therubyracer' # Required by less-rails
gem 'coffee-rails'
gem 'uglifier' # NOTE JS minification happens in requirejs-rails and is configured in requirejs.yml

group :development do
  gem 'bullet'
  gem 'ruby-growl' # used by bullet
  gem 'debugger'
  gem 'sunspot_solr', github: 'leppert/sunspot', branch: '2.0.0-rails4'
  gem 'progress_bar'
  gem 'better_errors'
  gem 'binding_of_caller' # for better_errors
  gem 'irbtools', require: false
  gem 'terminal-notifier', require: false # or else irbtools will complain
  gem 'meta_request' # for RailsPanel
end

group :development, :test do
  gem 'teaspoon', github: 'modeset/teaspoon'
  gem 'tapout'
  gem 'rspec-rails'
  #gem 'rspec-ontap'
  gem 'spork-rails', github: 'A-gen/spork-rails'
  gem 'watchr'
end
