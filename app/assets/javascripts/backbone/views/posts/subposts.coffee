define [
  "jquery"
  "app/views/base/collection"
  "app/views/posts/subpost"
  "text!posts/subposts.css"
], ($, CollectionView, SubPostView, css) ->
  $("<style>").html(css).appendTo("head")

  class SubPostsView extends CollectionView
    modelView: SubPostView

    className: "r_subposts"
