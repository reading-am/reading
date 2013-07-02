if Rails.env.development?
  Rack::MiniProfiler.config.skip_paths << '/teaspoon'
end
