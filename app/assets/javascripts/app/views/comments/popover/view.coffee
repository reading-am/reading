define [
  "backbone"
  "app/views/components/popover/view"
  "app/views/comments/comment/view"
  "text!app/views/comments/popover/template.mustache"
  "text!app/views/comments/popover/styles.css"
], (Backbone, Popover, CommentView, template, styles) ->

  class CommentPopover extends Popover
    @assets
      styles: styles
      template: template

    render: =>
      @$el.html(@template())

      child_view = new CommentView
        size: "medium"
        model: @model
        tagName: "div"
        className: "r_content r_comment"

      @$el.prepend(child_view.render().el)

      return this
