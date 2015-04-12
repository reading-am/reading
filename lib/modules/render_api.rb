module RenderApi
  def render_api(path=nil, **args, &block)
    path_root = Rails.root.join("app", "views", "api", "v#{API_VERSION}")
    view = ApplicationController.view_context_class.new(path_root)

    return JbuilderTemplate.new(view).tap(&block) if block

    # An object was passed in alone
    if path && !path.is_a?(String) && !path.is_a?(Symbol)
      name = path.class.name.downcase
      args[:partial] ||= "#{name.pluralize}/#{name}"
      args[:"#{name}"] ||= path
      path = nil
    end

    unless path
      path = args.delete(:partial)
      parts = path.split('/')
      # add an underscore for the partial
      parts[-1] = "_#{parts[-1]}" unless parts[-1][0] == '_'
      path = parts.join('/')
    end

    JbuilderTemplate.new(view).tap do |json|
      args_string = ''
      (args || {}).keys.each do |k|
        args_string += "#{k} = args[:#{k}]\n"
      end
      eval(args_string + File.open(path_root.join(path + '.json.jbuilder')).read)
    end
  end
end
