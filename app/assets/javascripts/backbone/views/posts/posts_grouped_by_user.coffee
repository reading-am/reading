define [
  "underscore"
  "app/views/base/collection"
  "app/models/post"
  "app/collections/posts"
  "app/views/posts/post_on_page"
], (_, CollectionView, Post, Posts, PostView) ->

  class PostsGroupedByUserView extends CollectionView
    modelView: PostView

    initialize: (options) ->
      @filtered = new Posts
      super()

    is_online: (ids, status) =>
      ids = [ids] unless _.isArray ids

      @filtered.each (post, i) =>
        if _.contains ids, post.get("user").id
          @$("li:eq(#{i})").toggleClass("r_online", status)

    is_typing: (id, status) ->
      @filtered.each (post, i) =>
        if id is post.get("user").id
          @$("li:eq(#{i})").toggleClass("r_typing", status)

    addAll: =>
      @collection.each (post) => @addOne post, false

    addOne: (post, slide) =>
      old = @filtered.find (p) -> post.get("user").id is p.get("user").id

      if !old or old.id < post.id
        li_len = @$("li").length

        if old?.id < post.id
          @filtered.remove old
          --li_len # you can't recount after removal because the slide() timing means it's still on the DOM

        @filtered.add post

        view = new @modelView model: post

        i = @filtered.indexOf(post)
        $el = view.render().$el

        $el.addClass("r_current_post") if post.id is Post::current.id
        $el.hide() if slide

        # add posts in order if we're only adding one of them
        if li_len is @filtered.length-1 and i < li_len
          @$("li:eq(#{i})").before($el)
        else
          @$el.append($el)

        $el.slideDown() if slide
