define [
  "app/views/base/collection/view"
  "app/views/comments/comment/view"
  "text!app/views/comments/comments/template.mustache"
  "text!app/views/comments/comments/styles.css"
], (CollectionView, CommentView, template, styles) ->

  class CommentsView extends CollectionView
    @assets
      styles: styles
      template: template

    modelView: CommentView
    animation: false
    empty_msg: "You get to be the first commenter! FIRST!"
