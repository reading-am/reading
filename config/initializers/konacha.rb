Konacha.configure do |config|
  config.spec_dir  = "spec/javascripts"
  config.driver    = :selenium
end if defined?(Konacha)
