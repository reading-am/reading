define [
  "underscore"
  "jquery"
  "app/views/base/collection"
  "app/views/posts/subpost/view"
  "text!app/views/posts/subposts/template.mustache"
  "text!app/views/posts/subposts/styles.css"
], (_, $, CollectionView, SubPostView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class SubPostsView extends CollectionView
    @parse_template template
    modelView: SubPostView

    initialize: ->
      load_css()
      super()
