class WaybackJob < ActiveJob::Base
  def perform url
    Curl.get "http://web.archive.org/save/#{url}"
  end
end
