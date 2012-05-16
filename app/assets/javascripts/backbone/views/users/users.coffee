define ["backbone","app/views/users/user"], (Backbone, UserView) ->

  class UsersView extends Backbone.View
    tagName: "ul"

    initialize: ->
      @collection.bind "reset", @addAll

    addAll: =>
      @collection.each(@addOne)

    addOne: (user) =>
      view = new UserView({model : user})
      @$el.append(view.render().el)

    render: =>
      @addAll()
      return this
