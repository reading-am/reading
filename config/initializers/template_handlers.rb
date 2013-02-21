require 'handlebars'
require 'tilt'


module Handlebars
  class Tilt < ::Tilt::Template
    def self.default_mime_type
      'application/javascript'
    end

    def prepare

    end

    def evaluate(scope, locals, &block)
      scope.extend Scope
      hbsc = Handlebars::TemplateHandler.handlebars.precompile data
      if scope.partial?
        <<-JS
        ;(function() {
          var template = Handlebars.template
          var fucknet = true
          Handlebars.registerPartial('#{scope.partial_name}', template(#{hbsc}));
        })()
        JS
      else
        <<-JS
        ;(function() {
          var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
          #{scope.template_path}
          namespace['#{scope.template_name}'] = template(#{hbsc});
        })()
        JS
      end
    end

    module Scope
      def partial?
        File.basename(logical_path).start_with?('_')
      end

      def partial_name
        "#{File.dirname(logical_path)}/#{File.basename(logical_path, '.hbs').gsub(/^_/,'')}".gsub(/^\.+/,'')
      end

      def template_path
        branches = File.dirname(logical_path).split('/').reject{|p| p == '.'}
        <<-ASSIGN
        var branches = #{branches.inspect}
        var namespace = templates
        for (var path = branches.shift(); path; path = branches.shift()) {
            namespace[path] = namespace[path] || {}
            namespace = namespace[path]
        }
        ASSIGN
      end

      def template_name
        File.basename(logical_path, '.hbs')
      end
    end
  end

  class TemplateHandler

  def self.handlebars
    @context ||= new_context
  end

  def self.call(template)
    %{
      handler = ::Handlebars::TemplateHandler
      handlebars = handler.handlebars
      handler.with_view(self) do
        handlebars.compile(#{template.source.inspect}).call(assigns).force_encoding(Encoding.default_external).html_safe
      end
    }
  end

  def self.with_view(view)
    original_view = data['view']
    data['view'] = view
    yield
  ensure
    data['view'] = original_view
  end

  def self.new_context
    Handlebars::Context.new.tap do |context|
      context['rails'] = {}
      context.partial_missing do |name|
        lookup_context = data['view'].lookup_context
        prefixes = lookup_context.prefixes.dup
        prefixes.push ''
        partial = lookup_context.find(name, prefixes, true)
        lambda do |this, context|
          if partial.handler == self
            handlebars.compile(partial.source).call(context)
          else
            data['view'].render :partial => name, :locals => context
          end
        end
      end
    end
  end

  def self.data
    @context['rails']
  end
end
end

module Handlebars::Rails
  class Engine < ::Rails::Engine

    unless config.respond_to?(:handlebars)
      config.handlebars = ActiveSupport::OrderedOptions.new
    end

    initializer 'handlebars.handler.setup', :before => :add_view_paths do |app|
      app.paths['app/views'] << 'app/assets/javascripts/backbone/templates'
      ActiveSupport.on_load(:action_view) do
        ActionView::Template.register_template_handler(:hbs, ::Handlebars::TemplateHandler)
      end
    end

    initializer 'handlebars.precompiler.setup', :group => :all do |app|
      app.assets.append_path 'app/assets/javascripts/backbone/templates'
      app.assets.register_engine '.hbs', Handlebars::Tilt
    end
  end
end