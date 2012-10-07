define [
  "backbone"
  "app/views/posts/post"
], (Backbone, PostView) ->

  class PostsView extends Backbone.View
    tagName: "ul"

    initialize: (options) ->
      @collection.bind "reset", @addAll
      @collection.bind "add", @addOne

    addAll: =>
      @collection.each @addOne

    addOne: (post) =>
      view = new PostView model:post

      i = @collection.length-1 - @collection.indexOf(post)
      li_len = @$("ul li").length

      # add posts in order if we're only adding one of them
      if li_len is @collection.length-1 and i
        @$("li:eq(#{i-1})").after(view.render().el)
      else
        @$el.prepend(view.render().el)

    render: =>
      @addAll()
      return this
