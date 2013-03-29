define [
  "underscore"
  "app/views/base/collection"
  "app/views/users/user"
], (_, CollectionView, UserView) ->

  class UsersView extends CollectionView
    modelView: UserView

    initialize: (options) ->
      @size = options.size ? "small"
      super()
