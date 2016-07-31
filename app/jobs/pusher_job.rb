class PusherJob < ApplicationJob
  include RenderApi

  def perform(action, obj)
    ApplicationRecord.connection_pool.with_connection do
      # Pusher can only take channels in groups of 100 or less
      obj.channels.each_slice(100).to_a.each do |channels|
        Pusher.trigger(channels, action.to_s, render_api(obj))
      end
    end
  end
end
