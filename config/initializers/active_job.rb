ActiveJob::Base.queue_adapter = Rails.env.test? ? :test : :sidekiq
