define [
  "app/views/base/collection"
  "app/views/posts/post_alt"
], (CollectionView, PostView) ->

  class PostsView extends CollectionView
    modelView: PostView
    sort: "desc"
