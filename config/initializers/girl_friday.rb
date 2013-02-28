PUSHER_QUEUE = GirlFriday::WorkQueue.new(:pusher_msg, :size => 3) do |msg|
  Pusher[msg[:channel]].trigger(msg[:action], msg[:msg])
end
