module Broadcaster

  def self.signal action, obj
    simple_obj = obj.simple_obj
    obj.channels.each do |channel| PUSHER_QUEUE << {:channel => channel, :action => action, :msg => simple_obj} end
  end

end
