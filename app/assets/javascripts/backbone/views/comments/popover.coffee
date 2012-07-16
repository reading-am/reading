define [
  "jquery"
  "backbone"
  "app/views/components/popover"
  "app/views/comments/comment"
  "text!comments/popover.css"
], ($, Backbone, Popover, CommentView, css) ->
	
  $("<style>").html(css).appendTo("head")

  class CommentPopover extends Popover
    id: "r_comment_popover"

    render: =>
      @$el.html(@template())

      child_view = new CommentView
        size: "medium"
        model: @model
        tagName: "div"
        className: "r_content r_comment"

      @$el.prepend(child_view.render().el)

      return this
