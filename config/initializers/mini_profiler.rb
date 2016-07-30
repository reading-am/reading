if Rails.env.development? && defined?(Rack::MiniProfiler)
  Rack::MiniProfiler.config.skip_paths ||= []
  Rack::MiniProfiler.config.skip_paths << '/teaspoon'
end
