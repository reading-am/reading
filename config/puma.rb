# via: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#config

workers Integer(ENV['WORKER_COUNT'] || 2)

min_threads = Integer(ENV['MIN_THREADS'] || 5)
max_threads = Integer(ENV['MAX_THREADS'] || 10)
threads min_threads, max_threads

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  ApplicationRecord.establish_connection
end
