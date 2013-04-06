define [
  "app/views/posts/post_on_page/view"
  "text!app/views/posts/subpost/template.mustache"
  "text!app/views/posts/subpost/styles.css"
], (PostOnPageView, template, styles) ->

  class SubPostView extends PostOnPageView
    @assets
      styles: styles
      template: template
