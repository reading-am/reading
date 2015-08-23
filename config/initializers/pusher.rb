case Rails.env
when 'development'
  %w(host port app_id key secret).each do |p|
    v = ENV["PUSHER_#{p.upcase}"]
    next unless v.present?
    # The port needs to be an integer but the .env gets passed as a string
    Pusher.send("#{p}=", v.to_i != 0 || v == '0' ? v.to_i : v)
  end
end
