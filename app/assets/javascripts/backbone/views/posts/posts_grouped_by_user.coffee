define [
  "underscore"
  "backbone"
  "app/models/post"
  "app/collections/posts"
  "app/views/posts/post_on_page"
], (_, Backbone, Post, Posts, PostView) ->

  class PostsGroupedByUserView extends Backbone.View
    tagName: "ul"

    initialize: (options) ->
      @filtered = new Posts

      @collection.bind "reset", @addAll
      @collection.bind "add", @addOne

    is_online: (ids, status) =>
      ids = [ids] unless _.isArray ids

      @filtered.each (post, i) =>
        if _.contains ids, post.get("user").id
          @$("li:eq(#{@filtered.length - i - 1})").toggleClass("r_online", status)

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

        $el.addClass("r_current_post") if post.id is Post::current.id
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
