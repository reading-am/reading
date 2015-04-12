class WaybackJob
  include SuckerPunch::Job
  workers 4

  def perform url
    Curl.get "http://web.archive.org/save/#{url}"
  end

end
