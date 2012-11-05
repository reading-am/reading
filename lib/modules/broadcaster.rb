module Broadcaster

  def self.signal action, obj
    async = defined? PUSHER_QUEUE # this won't exist in the console
    simple_obj = obj.simple_obj

    obj.channels.each do |channel|
      msg = {:channel => channel, :action => action, :msg => simple_obj}
      if async
        PUSHER_QUEUE << msg
      else
        Pusher[msg[:channel]].trigger(msg[:action], msg[:msg])
      end
    end
  end

end
