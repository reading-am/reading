reading.define [
  "backbone"
  "handlebars"
  "app/views/users/users"
], (Backbone, Handlebars, UsersView) ->

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
          <a href=\"/users/friends\" {{#friends}}class=\"active\"{{/friends}}>Friends</a>
          <form class=\"search\" action=\"/users/search\" {{#search}}class=\"active\"{{/search}}>
            <input type=\"text\" name=\"q\" value=\"{{query}}\" placeholder=\"Search names and alter egos\">
          </form>
        </nav>
      </div>
      <div class=\"row\">
        <div id=\"users\" class=\"span7 offset1\"></div>
      </div>
    "

    initialize: (options) ->
      @section = options.section
      @users_view = new UsersView
        collection: options.collection
        className: "r_users"

    after_insert: ->
      @$("input").focus() if @section is "search"

    render: ->
      data = query: @users_view.collection.query
      data[@section] = true

      @$el.html(@template(data))
      @$("#users").html(@users_view.render().el)

      return this
