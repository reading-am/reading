define [
  "underscore"
  "app/views/base/collection"
  "app/views/users/user/view"
  "text!app/views/users/user/template.mustache"
], (_, CollectionView, UserView, template) ->

  class UsersView extends CollectionView
    @assets
      template: template
    modelView: UserView

    initialize: (options) ->
      @size = options.size ? "small"
      super options
