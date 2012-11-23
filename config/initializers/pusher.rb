case Rails.env
#when 'production'
  #Pusher.host   = 'ws.reading.am'
when 'development'
  # NOTE app_id can be anything.
  # Not used by Slanger but required by the Pusher lib
  Pusher.app_id = '10842'
  Pusher.host   = 'localhost'
end

case Rails.env
when 'development'#, 'production'
  Pusher.port   = 4567
  Pusher.key    = ENV['READING_SLANGER_KEY']
  Pusher.secret = ENV['READING_SLANGER_SECRET']
end
