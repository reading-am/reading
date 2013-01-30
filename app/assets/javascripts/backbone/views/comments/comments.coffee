define [
  "underscore"
  "jquery"
  "app/views/base/collection"
  "app/views/comments/comment"
  "text!comments/comments.css"
], (_, $, CollectionView, CommentView, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class CommentsView extends CollectionView
    modelView: CommentView
    className: "r_comments"

    initialize: ->
      load_css()
      super()
