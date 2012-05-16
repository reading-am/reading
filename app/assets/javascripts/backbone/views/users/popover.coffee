define ["jquery","backbone","handlebars"], ($, Backbone, Handlebars) ->

  class UserPopoverView extends Backbone.View

    template: Handlebars.compile "
      <div></div>
      <iframe src=\"{{url}}\"></iframe>
    "

    tagName: "div"
    id: "r_popover"

    events:
      "click" : "close"

    close: ->
      @$el.remove()

    render: ->
      @$el.html(@template(@model.toJSON()))
      $("body").prepend @el
      @$el.fadeIn("fast")
