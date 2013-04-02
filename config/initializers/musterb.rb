require 'musterb/template_handler'

ActionController::Base.prepend_view_path File.join(Rails.root, "app", "assets", "javascripts", "app", "views")
ActionMailer::Base.prepend_view_path File.join(Rails.root, "app", "assets", "javascripts", "app", "views")
ActionView::Template.register_template_handler :mustache, Musterb::TemplateHandler

Musterb.configure do |config|
  config.partial_method = :file
end
