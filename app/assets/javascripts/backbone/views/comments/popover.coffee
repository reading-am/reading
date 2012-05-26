define [
  "backbone"
  "handlebars"
  "models/current_user"
  "app/views/comments/comment"
  "css!components/popover"
], (Backbone, Handlebars, current_user, CommentView) ->

  class CommentPopover extends Backbone.View
    template: Handlebars.compile "<div class=\"r_blocker\"></div>"

    id: "r_comment_popover"
    className: "r_popover"

    render: =>
      @$el.html(@template())

      child_view = new CommentView
        model: @model
        tagName: "div"
        className: "r_content r_comment"

      @$el.prepend(child_view.render().el)

      return this
