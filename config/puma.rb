preload_app!
 
min_threads = Integer(ENV['MIN_THREADS'] || 8)
max_threads = Integer(ENV['MAX_THREADS'] || 12)
 
threads min_threads, max_threads
workers Integer(ENV['WORKER_COUNT'] || 2)
 
on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    config = Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 #seconds
    config['pool']              = ENV['DB_POOL'] || 5
    ActiveRecord::Base.establish_connection(config)
  end
end
