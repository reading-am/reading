define [
  "underscore"
  "jquery"
  "mustache"
  "app/views/posts/post_on_page/view"
  "text!app/views/posts/subpost/wrapper.mustache"
  "text!app/views/posts/subpost/template.mustache"
  "text!app/views/posts/subpost/styles.css"
], (_, $, Mustache, PostOnPageView, wrapper, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class SubPostView extends PostOnPageView
    template: Mustache.compile template

    initialize: ->
      load_css()
      super()

  SubPostView::wrap wrapper
