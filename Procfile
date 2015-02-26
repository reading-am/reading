web: bundle exec puma -p $PORT
worker: bundle exec rake jobs:work
search: elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml
memcached: memcached -v
