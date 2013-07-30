define [
  "backbone"
  "app/models/user"
  "app/views/users/users/view"
  "app/views/users/user/medium/view"
  "text!app/views/users/find_people/template.mustache"
], (Backbone, User, UsersView, UserMediumView, template) ->

  class FindPeopleView extends Backbone.View
    @assets
      template: template

    initialize: (options) ->
      @collection.bind "sync", @sync, this

      @section = options.section
      @users_view = new UsersView
        collection: @collection
        className: "r_users"
        modelView: UserMediumView

    sync: ->
      if @collection.length is 0
        @status
          .text("Huh, we didn't find anyone.")
          .show()
      else
        @status.hide()

    after_insert: ->
      @search.focus() if @section is "search"

    render: ->
      data =
        query:     @collection.params.q
        signed_in: User::current.signed_in()

      data[@section] = true

      @$el.html(@template(data))
      @$("#users").append(@users_view.render().el)

      @status = @$("#users .status")
      @search = @$("input")

      return this
