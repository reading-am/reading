define [
  "underscore"
  "backbone"
  "app/models/post"
  "app/collections/posts"
  "app/views/posts/post"
], (_, Backbone, Post, Posts, PostView) ->

  class PostsGroupedByUserView extends Backbone.View
    tagName: "ul"

    initialize: (options) ->
      @collection.bind "reset", @addAll
      @collection.bind "add", @addOne

    addAll: =>
      @collection.each @addOne

    addOne: (post) =>
      view = new PostView({model : post})

      i = @collection.length-1 - @collection.indexOf(post)
      li_len = @$("ul li").length

      # add posts in order if we're only adding one of them
      if li_len is @collection.length-1 and i
        @$("ul li:eq(#{i-1})").after(view.render().el)
      else
        @$("ul").prepend(view.render().el)

    render: =>
      @addAll()
      return this
