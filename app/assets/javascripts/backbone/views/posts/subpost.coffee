define [
  "jquery"
  "handlebars"
  "app/views/posts/post_on_page"
  "text!app/templates/posts/subpost.hbs"
  "text!posts/subpost.css"
], ($, Handlebars, PostOnPageView, template, css) ->
  $("<style>").html(css).appendTo("head")

  class SubPostView extends PostOnPageView
    template: Handlebars.compile template

    className: "r_post r_subpost"
