Stache.configure do |config|
  config.template_base_path = File.join(Rails.root, "app", "assets", "javascripts", "backbone", "templates")
  config.use :mustache
end
