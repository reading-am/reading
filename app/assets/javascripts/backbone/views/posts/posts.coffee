define [
  "app/views/base/collection"
  "app/views/posts/post"
], (CollectionView, PostView) ->

  class PostsView extends CollectionView
    modelView: PostView
    sort: "desc"
