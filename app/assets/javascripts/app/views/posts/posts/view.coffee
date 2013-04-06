define [
  "app/views/base/collection"
  "app/views/posts/post/view"
  "text!app/views/posts/posts/template.mustache"
], (CollectionView, PostView, template) ->

  class PostsView extends CollectionView
    @assets
      template: template
    modelView: PostView
