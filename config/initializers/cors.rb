# NOTE - this needs to be inserted at the top of the Rack middleware stack,
# before Rack::Cache or else it fails to insert the headers. Gleaned from:
# https://github.com/diaspora/diaspora/pull/2990

Rails.application.config.middleware.insert 0, Rack::Cors do
  allow do
    origins '*'
    resource %r{api/.*},
      :headers => :any,
      :methods => [:get, :post, :put, :patch, :delete]
    resource '/pusher/auth',
      :headers => :any,
      :methods => [:get, :post]
    resource %r{assets/.*},
      :headers => :any,
      :methods => :get
  end
end
