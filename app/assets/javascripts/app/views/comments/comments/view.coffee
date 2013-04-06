define [
  "app/views/base/collection"
  "app/views/comments/comment/view"
  "text!app/views/comments/comments/template.mustache"
  "text!app/views/comments/comments/styles.css"
], (CollectionView, CommentView, template, styles) ->

  class CommentsView extends CollectionView
    @assets
      styles: styles
      template: template
      
    modelView: CommentView
