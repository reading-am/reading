define [
  "jquery"
  "backbone"
  "handlebars"
  "app/models/post"
  "app/models/page" # this needs preloading
  "text!app/templates/posts/post_group.hbs"
], ($, Backbone, Handlebars, Post, Page, template) ->

  class PostNewView extends Backbone.View
    template: Handlebars.compile template

    events:
      "submit form": "submit"

    initialize: ->
      @model = new Post

    submit: ->
      params = url: @$("form input[type=text]").val()
      @model.save params, success: => @render()
      false

    render: =>
      json =
        page:
          title: @model.get("page").get("title")
          excerpt: @model.get("page").get("excerpt")
        user:
          display_name: @model.get("user").get("display_name")
          username: @model.get("user").get("username")

      $post = $(@template(json)).hide()
      @$el.after($post).slideUp()
      $post.slideDown()
