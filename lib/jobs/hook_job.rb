class HookJob
  include SuckerPunch::Job
  workers 4

  def perform hook, post, event_fired
    ActiveRecord::Base.connection_pool.with_connection do
      hook.send(hook.provider, post, event_fired)
    end
  end

end
