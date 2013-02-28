web: bundle exec puma -t 1:4 -b tcp://0.0.0.0:$PORT
worker: bundle exec rake jobs:work
search: bundle exec rake sunspot:solr:run
devmail: mailcatcher --foreground
testjs: rake konacha:serve
testrubyserver: bundle exec spork
testruby: rake watchr
