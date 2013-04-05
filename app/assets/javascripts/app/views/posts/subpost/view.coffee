define [
  "underscore"
  "jquery"
  "app/views/posts/post_on_page/view"
  "text!app/views/posts/subpost/template.mustache"
  "text!app/views/posts/subpost/styles.css"
], (_, $, PostOnPageView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class SubPostView extends PostOnPageView
    @parse_template template

    initialize: (options) ->
      load_css()
      super options
