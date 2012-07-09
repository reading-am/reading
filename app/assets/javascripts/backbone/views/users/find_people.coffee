reading.define [
  "backbone"
  "handlebars"
  "app/views/users/users"
], (Backbone, Handlebars, UsersView) ->

  class FindPeopleView extends Backbone.View
    template: Handlebars.compile "
      <div class=\"row\">
        <div class=\"span7 offset1\">
          <h1>Find People</h1>
        </div>
      </div>
      <div id=\"subnav\" class=\"row\">
        <nav class=\"span7 offset1\">
          <a href=\"/users/recommended\" class=\"active\">Recommended</a>
          <a href=\"/users/friends\">Friends</a>
          <form id=\"search\" action=\"/users/search\">
            <input type=\"text\" name=\"q\" placeholder=\"Search\">
          </form>
        </nav>
      </div>
      <div class=\"row\">
        <div id=\"users\" class=\"span7 offset1\"></div>
      </div>
    "

    initialize: (options) ->
      @users_view = new UsersView
        collection: options.collection
        className: "r_users"

    render: ->
      @$el.html(@template())
      @$("#users").html(
        if @users_view.collection.length
        then @users_view.render().el
        else "<h4>Nobody's here yet.</h4>"
      )
      return this
