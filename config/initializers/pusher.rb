case Rails.env
when 'development'
  # Slanger Override
  Pusher.host   = 'localhost'
  Pusher.port   = 4567

  # Pusher Dev Account
  Pusher.app_id = '10626'
  Pusher.key    = '***REMOVED***'
  Pusher.secret = 'fad1718be77fb47a5d91'
end
