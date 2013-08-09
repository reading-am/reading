define [
  "app/views/base/collection/view"
  "app/views/posts/subpost/view"
  "text!app/views/posts/subposts/template.mustache"
  "text!app/views/posts/subposts/styles.css"
], (CollectionView, SubPostView, template, styles) ->

  class SubPostsView extends CollectionView
    @assets
      styles: styles
      template: template

    modelView: SubPostView
