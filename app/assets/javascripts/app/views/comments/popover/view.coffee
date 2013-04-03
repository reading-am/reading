define [
  "underscore"
  "jquery"
  "backbone"
  "app/views/components/popover/view"
  "app/views/comments/comment/view"
  "text!app/views/comments/popover/template.mustache"
  "text!app/views/comments/popover/styles.css"
], (_, $, Backbone, Popover, CommentView, template. css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class CommentPopover extends Popover
    @parse_template template

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
