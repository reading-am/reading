::PUSHER_QUEUE = GirlFriday::WorkQueue.new(:pusher_msg, :size => 3) do |msg|
  Pusher.trigger (msg[:channel] || msg[:channels]), msg[:action], msg[:msg]
end
