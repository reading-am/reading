define [
  "underscore"
  "libs/backbone"
  "mustache"
], (_, Backbone, Mustache) ->

  Backbone.View.parse_template = (template) ->
    $el = Backbone.$(Mustache.render(template, {}))

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

    this::template = Mustache.compile(template.match(/>((.|\n|\r)*)</)[1])


  return Backbone
