module Broadcaster

  def self.signal action, obj
    async = defined? PUSHER_QUEUE # this won't exist in the console
    simple_obj = obj.simple_obj

    obj.channels.each do |channel|
      msg = {:channel => channel.to_s, :action => action.to_s, :msg => simple_obj}
      if async
        PUSHER_QUEUE << msg
      else
        Pusher[msg[:channel].to_s].trigger(msg[:action].to_s, msg[:msg])
      end
    end
  end

end
