require 'handlebars'

# This is a dirty hack I picked up from http://www.slideshare.net/digx/hardcore-extending-rails-3-from-railsconf-10
class HandlebarsHandler < ActionView::Template
  def self.call(template)
    <<-RUBY_CODE
      template = Handlebars::Context.new.compile('#{template.source}')
      vars = {}
      partial_renderer = @view_renderer.send(:_partial_renderer)
      vars.merge!(@_assigns)
      vars.merge!(local_assigns)
      # vars.merge!(partial_renderer.instance_variable_get('@options')[:context] || {})
      template.call(vars.as_json).html_safe
    RUBY_CODE
  end
end

ActionView::Template.register_template_handler(:hbs, HandlebarsHandler)