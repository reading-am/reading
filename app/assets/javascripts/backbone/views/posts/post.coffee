define [
  "backbone"
  "app/views/users/user"
], (Backbone, UserView) ->

  is_retina = window.devicePixelRatio > 1

  class PostView extends Backbone.View
    tagName: "li"
    className: "r_post"

    render: =>
      @user_view = new UserView model: @model.get("user"), size: "small"
      @$el.html(@user_view.render().el)

      return this
