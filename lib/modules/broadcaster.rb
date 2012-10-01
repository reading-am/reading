module Broadcaster

  def self.signal action, obj
    simple_obj = obj.simple_obj
    obj.channels.each do |channel| Pusher[channel].trigger_async(action, simple_obj) end
  end

end
