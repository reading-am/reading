module Broadcaster

  def self.signal action, obj
    async = defined? PUSHER_QUEUE # this won't exist in the console
    msg = {action: action.to_s, msg: obj.simple_obj}

    obj.channels.each_slice(100).to_a.each do |channels| # Pusher can only take channels in groups of 100 or less
      msg[:channels] = channels
      if async
        PUSHER_QUEUE << msg
      else
        Pusher.trigger msg[:channels], msg[:action], msg[:msg]
      end
    end
  end

end
