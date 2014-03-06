class Broadcaster
  include SuckerPunch::Job
  workers 4

  def perform action, obj
    ActiveRecord::Base.connection_pool.with_connection do
      obj.channels.each_slice(100).to_a.each do |channels| # Pusher can only take channels in groups of 100 or less
        Pusher.trigger(channels, action.to_s, obj.simple_obj)
      end
    end
  end

end
