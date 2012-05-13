ø.Views.Users ||= {}

class ø.Views.Users.UserPopoverView extends ø.Backbone.View

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
    ø.$("body").prepend @el
    @$el.fadeIn("fast")
