define [
  "backbone"
  "app/views/users/users/view"
  "app/views/users/user/medium/view"
  "text!app/views/users/followingers/template.mustache"
], (Backbone, UsersView, UserMediumView, template) ->

  class FollowingersView extends Backbone.View
    @assets
      template: template

    initialize: (options) ->
      @followers = options.followers
      @users_view = new UsersView
        collection: options.collection
        className: "r_users"
        modelView: UserMediumView

    render: ->
      @$el.html(@template(followers: @followers, user: @model.toJSON()))
      @$("#users").html(
        if @users_view.collection.length
        then @users_view.render().el
        else "<h4>Nobody's here yet.</h4>"
      )
      return this
