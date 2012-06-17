desc "Run spork"
task :spork do
  sh %{bundle exec spork}
end
