# via http://codeglot.com/posts/25-simple_way_to_keep_smaller_apps_loaded_on_herkou

require 'rufus/scheduler'
scheduler = Rufus::Scheduler.start_new

scheduler.every '10m' do
   require "net/http"
   require "uri"
   url = "http://reading.am"
   Net::HTTP.get_response(URI.parse(url))
end
