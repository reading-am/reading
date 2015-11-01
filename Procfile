web: bundle exec puma -p $PORT
worker: bundle exec sidekiq config/sidekiq.yml
search: elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml
memcached: memcached -v
