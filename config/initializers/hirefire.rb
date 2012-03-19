# HireFire.configure do |config|
#   config.max_workers = 10
#   config.job_worker_ratio = [
#     { :when => lambda {|jobs| jobs < 15 }, :workers => 1 },
#     { :when => lambda {|jobs| jobs < 35 }, :workers => 2 },
#     { :when => lambda {|jobs| jobs < 60 }, :workers => 3 },
#     { :when => lambda {|jobs| jobs < 80 }, :workers => 4 }
#   ]
# end
