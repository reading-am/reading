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
      @collection.each (post) => @addOne post, false

    addOne: (post, slide) =>
      old = @filtered.find (p) -> post.get("user").id is p.get("user").id

      if !old or old.id < post.id
        @filtered.remove old if old?.id < post.id
        @filtered.add post

        view = new PostView model: post

        i = @filtered.length-1 - @filtered.indexOf(post)
        li_len = @$("ul li").length
        $el = view.render().$el
        $el.hide() if slide

        # add posts in order if we're only adding one of them
        if li_len is @filtered.length-1 and i
          @$("li:eq(#{i-1})").after($el)
        else
          @$el.prepend($el)

        $el.slideDown() if slide

    render: =>
      @addAll()
      return this
