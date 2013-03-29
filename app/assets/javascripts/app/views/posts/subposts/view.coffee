define [
  "underscore"
  "jquery"
  "app/views/base/collection"
  "app/views/posts/subpost/view"
  "text!app/views/posts/subposts/styles.css"
], (_, $, CollectionView, SubPostView, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class SubPostsView extends CollectionView
    modelView: SubPostView

    className: "r_subposts"

    initialize: ->
      load_css()
      super()
