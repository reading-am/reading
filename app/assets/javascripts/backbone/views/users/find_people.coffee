define [
  "backbone"
  "mustache"
  "app/models/current_user"
  "app/views/users/users"
  "text!app/templates/users/find_people.mustache"
], (Backbone, Handlebars, current_user, UsersView, template) ->

  class FindPeopleView extends Backbone.View
    template: Handlebars.compile template

    initialize: (options) ->
      @collection.bind "reset", @reset

      @section = options.section
      @users_view = new UsersView
        collection: @collection
        size: "medium"
        className: "r_users"

    reset: =>
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
        query:     @collection.query
        logged_in: current_user.logged_in()

      data[@section] = true

      @$el.html(@template(data))
      @$("#users").append(@users_view.render().el)

      @status = @$("#users .status")
      @search = @$("input")

      return this
