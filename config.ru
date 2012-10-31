# This file is used by Rack-based servers to start the application.

# for use with: https://github.com/ejschmitt/delayed_job_web
DelayedJobWeb.use Rack::Auth::Basic do |username, password|
  username == ENV['READING_AUTH_BASIC_USER'] && password == ENV['READING_AUTH_BASIC_PASS']
end

require ::File.expand_path('../config/environment',  __FILE__)
run Reading::Application
