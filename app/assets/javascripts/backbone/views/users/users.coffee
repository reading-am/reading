define [
  "underscore"
  "backbone"
  "app/views/users/user"
], (_, Backbone, UserView) ->

  class UsersView extends Backbone.View
    tagName: "ul"

    initialize: ->
      @subviews = []
      @collection.bind "reset", @addAll
      @collection.bind "remove", @removeOne

    addAll: =>
      @collection.each(@addOne)

    addOne: (user) =>
      view = new UserView model: user, size: "small"
      @subviews.push(view)
      @$el.append(view.render().el)
 
    removeOne: (model) =>
      view = _(@subviews).select((v) -> v.model is model)[0]
      @subviews = _(@subviews).without(view)
      view.remove()

    render: =>
      @addAll()
      return this
