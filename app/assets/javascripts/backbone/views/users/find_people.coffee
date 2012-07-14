define [
  "backbone"
  "handlebars"
  "models/current_user"
  "app/views/users/users"
], (Backbone, Handlebars, current_user, UsersView) ->

  class FindPeopleView extends Backbone.View
    template: Handlebars.compile "
      <div id=\"header_card\" class=\"row\">
        <div class=\"span7 offset1\">
          <h1>Find People</h1>
        </div>
        <div class=\"span7 offset1\">
          Following good people on Reading makes you smarter, it's a fact.
        </div>
      </div>
      <div id=\"subnav\" class=\"row\">
        <nav class=\"span7 offset1\">
          <a href=\"/users/recommended\" {{#recommended}}class=\"active\"{{/recommended}}>Recommended</a>
          {{#logged_in}}<a href=\"/users/friends\" {{#friends}}class=\"active\"{{/friends}}>Outside Friends</a>{{/logged_in}}
          <form class=\"search\" action=\"/users/search\" {{#search}}class=\"active\"{{/search}}>
            <input type=\"text\" name=\"q\" value=\"{{query}}\" placeholder=\"Search names and alter egos\">
          </form>
        </nav>
      </div>
      <div class=\"row\">
        <div id=\"users\" class=\"span7 offset1\">
          <div class=\"status\">Loading Awesome People...</div>
        </div>
      </div>
    "

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
