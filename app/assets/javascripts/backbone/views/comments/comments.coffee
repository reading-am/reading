define [
  "app/views/base/collection"
  "app/views/comments/comment"
], (CollectionView, CommentView) ->

  class CommentsView extends CollectionView
    modelView: CommentView
    className: "r_comments_list"
