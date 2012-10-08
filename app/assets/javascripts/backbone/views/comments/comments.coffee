define [
  "app/views/base/collection"
  "app/views/comments/comment"
], (CollectionView, CommentView) ->

  class CommentsView extends CollectionView
    modelView: CommentView
    sort: "desc"
    className: "r_comments_list"
