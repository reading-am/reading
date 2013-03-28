define [
  "underscore"
  "jquery"
  "mustache"
  "app/views/posts/post_on_page"
  "text!app/templates/posts/subpost.mustache"
  "text!posts/subpost.css"
], (_, $, Mustache, PostOnPageView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class SubPostView extends PostOnPageView
    template: Mustache.compile template

    initialize: ->
      load_css()
      super()
