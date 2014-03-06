web: bundle exec puma -p $PORT
worker: bundle exec rake jobs:work
search: bundle exec rake sunspot:solr:run
memcached: memcached -v
devmail: mailcatcher --foreground
testrubyserver: bundle exec spork
testruby: rake watchr
