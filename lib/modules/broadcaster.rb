module Broadcaster

  def self.signal action, obj
    async = defined? PUSHER_QUEUE # this won't exist in the console
    simple_obj = obj.simple_obj

    obj.channels.each_slice(100).to_a.each do |channels|
      msg = {:channels => channels, :action => action.to_s, :msg => simple_obj}
      if async
        PUSHER_QUEUE << msg
      else
        Pusher.trigger msg[:channels], msg[:action].to_s, msg[:msg]
      end
    end
  end

end
