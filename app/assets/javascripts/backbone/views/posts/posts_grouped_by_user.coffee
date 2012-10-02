define [
  "underscore"
  "backbone"
  "app/collections/posts"
  "app/views/posts/post"
], (_, Backbone, Posts, PostView) ->

  class PostsGroupedByUserView extends Backbone.View
    tagName: "ul"

    initialize: (options) ->
      @filtered = new Posts

      @collection.bind "reset", @addAll
      @collection.bind "add", @addOne

    addAll: =>
      @collection.each(@addOne)

    addOne: (post) =>
      old = @filtered.find (p) -> post.get("user").id is p.get("user").id

      if !old or old.id < post.id
        @filtered.remove old if old?.id < post.id
        @filtered.add post

        view = new PostView model: post

        i = @filtered.length-1 - @filtered.indexOf(post)
        li_len = @$("ul li").length

        # add posts in order if we're only adding one of them
        if li_len is @filtered.length-1 and i
          @$("li:eq(#{i-1})").after(view.render().el)
        else
          @$el.prepend(view.render().el)

    render: =>
      @addAll()
      return this
