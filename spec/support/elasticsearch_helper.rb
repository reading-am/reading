# via: http://pivotallabs.com/rspec-elasticsearchruby-elasticsearchmodel/

require 'rake'
require 'elasticsearch/extensions/test/cluster/tasks'

RSpec.configure do |config|
  # Snipped other config.
  config.before :each, elasticsearch: true do
    Elasticsearch::Extensions::Test::Cluster.start(port: 9200, nodes: 1) unless Elasticsearch::Extensions::Test::Cluster.running?(on: 9200)
  end

  config.after :each, elasticsearch: true do
    Elasticsearch::Model.client.indices.delete index: 'all'
  end

  config.after :suite do
    Elasticsearch::Extensions::Test::Cluster.stop(port: 9200) if Elasticsearch::Extensions::Test::Cluster.running?(on: 9200)
  end
end
