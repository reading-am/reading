case Rails.env
when 'development'
  ['host','port','app_id','key','secret'].each do |p|
    v = ENV["READING_PUSHER_#{p.upcase}"]
    if !v.blank?
      # The port needs to be an actual integer but the .env gets passed as a string
      Pusher.send("#{p}=", v.to_i != 0 || v == '0' ? v.to_i : v)
    end
  end
end
