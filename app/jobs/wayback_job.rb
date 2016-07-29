class WaybackJob < ApplicationJob
  def perform url
    Curl.get "http://web.archive.org/save/#{url}"
  end
end
