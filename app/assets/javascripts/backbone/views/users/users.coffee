ø.Views.Users ||= {}

class ø.Views.Users.UsersView extends ø.Backbone.View
  tagName: "ul"

  initialize: ->
    @collection.bind "reset", @addAll

  addAll: =>
    @collection.each(@addOne)

  addOne: (user) =>
    view = new ø.Views.Users.UserView({model : user})
    @$el.append(view.render().el)

  render: =>
    @addAll()
    return this
