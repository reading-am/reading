Konacha.configure do |config|
  config.spec_dir  = "test/javascripts"
  config.driver    = :selenium
end if defined?(Konacha)
