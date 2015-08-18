# for use with: https://github.com/ejschmitt/delayed_job_web
DelayedJobWeb.use Rack::Auth::Basic do |username, password|
  username == ENV['AUTH_BASIC_USER'] && password == ENV['AUTH_BASIC_PASS']
end
