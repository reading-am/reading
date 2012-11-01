web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec rake jobs:work
search: bundle exec rake sunspot:solr:run
