case Rails.env
when 'development'
  # Slanger Override
  Pusher.host   = 'localhost'
  Pusher.port   = 4567

  # Pusher Dev Account
  Pusher.app_id = '10626'
  Pusher.key    = ENV['READING_SLANGER_KEY']
  Pusher.secret = ENV['READING_SLANGER_SECRET']
end
