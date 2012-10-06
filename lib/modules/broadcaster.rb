module Broadcaster

  def self.signal action, obj
    # If we have an eventmachine loop, use async triggering
    method = (defined?(EventMachine) && EventMachine.reactor_running?) ? 'trigger_async' : 'trigger'

    simple_obj = obj.simple_obj
    obj.channels.each do |channel| Pusher[channel].send(method, action, simple_obj) end
  end

end
