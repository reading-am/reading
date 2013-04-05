define [
  "underscore"
  "jquery"
  "app/views/base/collection"
  "app/views/comments/comment/view"
  "text!app/views/comments/comments/template.mustache"
  "text!app/views/comments/comments/styles.css"
], (_, $, CollectionView, CommentView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class CommentsView extends CollectionView
    @parse_template template
    modelView: CommentView

    initialize: (options) ->
      load_css()
      super options
