define [
  "underscore"
  "jquery"
  "handlebars"
  "app/views/posts/post_on_page"
  "text!app/templates/posts/subpost.hbs"
  "text!posts/subpost.css"
], (_, $, Handlebars, PostOnPageView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class SubPostView extends PostOnPageView
    template: Handlebars.compile template

    className: "r_post r_subpost"

    initialize: ->
      load_css()
      super()
