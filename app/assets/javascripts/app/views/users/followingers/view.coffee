define [
  "backbone"
  "mustache"
  "app/views/users/users/view"
  "text!app/views/users/followingers/template.mustache"
], (Backbone, Mustache, UsersView, template) ->

  class FollowingersView extends Backbone.View
    template: Mustache.compile template

    initialize: (options) ->
      @followers = options.followers
      @users_view = new UsersView
        collection: options.collection
        size: "medium"
        className: "r_users"

    render: ->
      @$el.html(@template(followers: @followers, user: @model.toJSON()))
      @$("#users").html(
        if @users_view.collection.length
        then @users_view.render().el
        else "<h4>Nobody's here yet.</h4>"
      )
      return this
