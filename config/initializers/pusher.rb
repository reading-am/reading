case Rails.env
when 'development'
  ['host','port','app_id','key','secret'].each do |p|
    Pusher.send("#{p}=", ENV["READING_PUSHER_#{p.upcase}"]) unless ENV["READING_PUSHER_#{p.upcase}"].blank?
  end
end
