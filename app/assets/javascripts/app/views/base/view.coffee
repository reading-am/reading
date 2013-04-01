define [
  "underscore"
  "libs/backbone"
  "mustache"
], (_, Backbone, Mustache) ->

  Backbone.View::wrap = (wrapper) ->
    $el = Backbone.$(Mustache.render(wrapper, {}))

    @id =         @id         || $el.attr "id"
    @tagName =    @tagName    || $el.prop "tagName"
    @className =  @className  || $el.attr "class"

    @attributes ||= {}
    _.each $el[0].attributes, (el) =>
      if el.nodeName isnt "id" and el.nodeName isnt "class"
        @attributes[el.nodeName] ||= el.nodeValue

    return @constructor

  return Backbone
