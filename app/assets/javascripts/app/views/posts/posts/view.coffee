define [
  "app/views/base/collection"
  "app/views/posts/post/view"
], (CollectionView, PostView) ->

  class PostsView extends CollectionView
    modelView: PostView
