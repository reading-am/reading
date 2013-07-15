# config/unicorn.rb
worker_processes Integer(ENV['READING_UNICORN_WORKERS'] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end 

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # Config girl_friday queues
  # needs to be here when used with unicorn and preload_app true
  # from: https://github.com/mperham/girl_friday/issues/47
  require "#{Rails.root}/config/girl_friday"
end
