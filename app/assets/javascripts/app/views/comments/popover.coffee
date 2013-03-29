define [
  "underscore"
  "jquery"
  "backbone"
  "app/views/components/popover"
  "app/views/comments/comment"
  "text!comments/popover.css"
], (_, $, Backbone, Popover, CommentView, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class CommentPopover extends Popover
    id: "r_comment_popover"

    initialize: ->
      load_css()
      super()

    render: =>
      @$el.html(@template())

      child_view = new CommentView
        size: "medium"
        model: @model
        tagName: "div"
        className: "r_content r_comment"

      @$el.prepend(child_view.render().el)

      return this
