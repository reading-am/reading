preload_app!
 
min_threads = Integer(ENV['MIN_THREADS'] || 8)
max_threads = Integer(ENV['MAX_THREADS'] || 12)
 
threads min_threads, max_threads
workers Integer(ENV['WORKER_COUNT'] || 2)
