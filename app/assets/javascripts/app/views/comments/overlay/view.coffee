define [
  "app/views/components/overlay/view"
  "app/views/comments/comment/view"
  "text!app/views/comments/overlay/template.mustache"
  "text!app/views/comments/overlay/styles.css"
], (Overlay, CommentView, template, styles) ->

  class CommentOverlay extends Overlay
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
