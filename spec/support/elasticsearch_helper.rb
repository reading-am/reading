# via: http://pivotallabs.com/rspec-elasticsearchruby-elasticsearchmodel/

require 'rake'
require 'elasticsearch/extensions/test/cluster/tasks'

ELASTICSEARCH_PORT = 9200

RSpec.configure do |config|
  config.before(:each, elasticsearch: true) { start }
  config.after(:each, elasticsearch: true) { reset! }
  config.after(:suite) { stop }

  def start
    Elasticsearch::Extensions::Test::Cluster.start(port: ELASTICSEARCH_PORT, nodes: 1) unless running?
  end

  def stop
    Elasticsearch::Extensions::Test::Cluster.stop(port: ELASTICSEARCH_PORT) if running?
  end

  def reset!
    Elasticsearch::Model.client.indices.delete index: '_all' if running?
  end

  def running?
    Elasticsearch::Extensions::Test::Cluster.running?(on: ELASTICSEARCH_PORT)
  end
end
