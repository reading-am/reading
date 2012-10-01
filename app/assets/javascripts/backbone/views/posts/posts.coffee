define [
  "underscore"
  "backbone"
  "app/views/posts/post"
], (_, Backbone, PostView) ->

  class PostsView extends Backbone.View
    tagName: "ul"

    initialize: (options) ->
      @subviews = []
      @user_ids = []
      @grouped_posts = {}

      @collection.bind "reset", @addAll
      @collection.bind "remove", @removeOne

    addAll: =>
      @collection.each(@addOne)

    addOne: (post) =>
      uid = post.get("user").id

      if !_.include @user_ids, uid
        @user_ids.push uid
        @grouped_posts[uid] = []

        view = new PostView model: post
        @subviews.push(view)
        @$el.append(view.render().el)

      @grouped_posts[uid].push post

 
    removeOne: (model) =>
      view = _(@subviews).select((v) -> v.model is model)[0]

      if view # because of the grouping, we need to check to make sure we found a view
        @subviews = _(@subviews).without(view)
        view.remove()

    render: =>
      @addAll()
      return this
