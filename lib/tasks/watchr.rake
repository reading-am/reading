# from: http://www.rubyinside.com/how-to-rails-3-and-rspec-2-4336.html
desc "Run watchr"
task :watchr do
  sh %{bundle exec watchr .watchr}
end
