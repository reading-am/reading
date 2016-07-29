class HookJob < ApplicationJob
  def perform(hook, post, event_fired)
    ApplicationRecord.connection_pool.with_connection do
      hook.send(hook.provider, post, event_fired)
    end
  end
end
