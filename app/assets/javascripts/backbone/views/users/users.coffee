define [
  "underscore"
  "app/views/base/collection"
  "app/views/users/user"
], (_, CollectionView, UserView) ->

  class UsersView extends CollectionView
    modelView: UserView

    initialize: (options) ->
      @size = options.size ? "small"
      @subviews = []
      super()

    addOne: (user) =>
      view = new @modelView
        tagName: "li"
        model: user
        size: @size

      @subviews.push(view)
      @$el.append(view.render().el)
 
    removeOne: (model) =>
      view = _(@subviews).select((v) -> v.model is model)[0]
      @subviews = _(@subviews).without(view)
      view.remove()
