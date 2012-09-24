define [
  "underscore"
  "backbone"
  "app/views/posts/post"
], (_, Backbone, PostView) ->

  class PostsView extends Backbone.View
    tagName: "ul"

    initialize: (options) ->
      @subviews = []
      @collection.bind "reset", @addAll
      @collection.bind "remove", @removeOne

    addAll: =>
      @collection.each(@addOne)

    addOne: (post) =>
      view = new PostView model: post
      @subviews.push(view)
      @$el.append(view.render().el)
 
    removeOne: (model) =>
      view = _(@subviews).select((v) -> v.model is model)[0]
      @subviews = _(@subviews).without(view)
      view.remove()

    render: =>
      @addAll()
      return this
