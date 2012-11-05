case Rails.env
when 'production'
  Pusher.host   = 'ws.reading.am'
when 'development'
  Pusher.host   = 'localhost'
end

case Rails.env
when 'production', 'development'
  Pusher.port   = 4567
  Pusher.key    = ENV['READING_SLANGER_KEY']
  Pusher.secret = ENV['READING_SLANGER_SECRET']
end
