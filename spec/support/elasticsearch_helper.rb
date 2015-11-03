# via: http://pivotallabs.com/rspec-elasticsearchruby-elasticsearchmodel/

require 'rake'
require 'elasticsearch/extensions/test/cluster/tasks'

ELASTICSEARCH_PORT = 9200

RSpec.configure do |config|
  config.before(:each, elasticsearch: true) { start }
  config.after(:each, elasticsearch: true) { reset! }
  config.after(:suite) { stop }

  def start
    return if running?
    Elasticsearch::Extensions::Test::Cluster.start(port: ELASTICSEARCH_PORT, nodes: 1)
  end

  def stop
    return unless running?
    Elasticsearch::Extensions::Test::Cluster.stop(port: ELASTICSEARCH_PORT)
  end

  def reset!
    return unless running?
    begin
      Elasticsearch::Model.client.indices.delete index: '_all'
    rescue
      puts "Elasticsearch isn't configured to allow mass index deletion"
    end
  end

  def running?
    Elasticsearch::Extensions::Test::Cluster.running?(on: ELASTICSEARCH_PORT)
  end
end
