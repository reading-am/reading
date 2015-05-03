# Right now, Typhoeus and Patron have trouble with elasticsearch for some reason.
# If Typhoeus ever starts working, you'll need to uncomment the line below
# require 'typhoeus/adapters/faraday'

transport_configuration = lambda do |f|
  f.response :logger unless Rails.env.test?
  f.adapter  :net_http
end

uri = URI.parse(ENV['SEARCHBOX_SSL_URL'] || ENV['SEARCHBOX_URL'])
transport = Elasticsearch::Transport::Transport::HTTP::Faraday.new \
  hosts: [{ :scheme => uri.scheme, :user => uri.user, :password => uri.password, :host => uri.host, :path => uri.path, :port => uri.port.to_s }],
  &transport_configuration

Elasticsearch::Model.client = Elasticsearch::Client.new transport: transport
