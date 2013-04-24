define [
  "underscore"
  "jquery"
  "libs/backbone"
  "mustache"
], (_, $, Backbone, Mustache) ->

  Backbone.View.assets = (options) ->
    if options.styles
      # We save a reference to the parent's styles so they can be applied too
      styles = this::styles = options.styles
      parent_apply = this::apply_styles
      this::apply_styles = _.once =>
        parent_apply?()
        $("<style>").html(styles).appendTo("head")

    if options.template
      $el = Backbone.$(Mustache.render(options.template, {}))

      if id = $el.attr "id"
        this::id = id
      if tagName = $el.prop "tagName"
        this::tagName = tagName
      if className = $el.attr "class"
        this::className = className

      this::attributes ||= {}
      _.each $el[0].attributes, (el) =>
        if el.nodeName isnt "id" and el.nodeName isnt "class"
          this::attributes[el.nodeName] ||= el.nodeValue

      this::template = Mustache.compile(options.template.match(/>((.|\n|\r)*)</)[1])

  Backbone.View::_constructor = Backbone.View::constructor
  Backbone.View::constructor = (options) ->
    @apply_styles?()
    Backbone.View::_constructor.apply(this, arguments)


  return Backbone
