reading.define [
  "backbone"
  "handlebars"
  "app/views/users/users"
], (Backbone, Handlebars, UsersView) ->

  class FollowingersView extends Backbone.View
    template: Handlebars.compile "
      <div id=\"subnav\" class=\"row\">
        <nav class=\"span1\">
          <a href=\"/{{user.username}}\">« read</a>
        </nav>
        <div class=\"span7\">
          <h3>
            {{#if followers}}
              People Following {{user.first_name}}
            {{else}}
              People {{user.first_name}} is Following
            {{/if}}
          </h3>
        </div>
      </div>
      <div class=\"row\">
        <div id=\"users\" class=\"span7 offset1\"></div>
      </div>
    "

    initialize: (options) ->
      @followers = options.followers
      @users_view = new UsersView
        collection: options.collection
        className: "r_users"

    render: ->
      @$el.html(@template(followers: @followers, user: @model.toJSON()))
      @$("#users").html(
        if @users_view.collection.length
        then @users_view.render().el
        else "<h4>Nobody's here yet.</h4>"
      )
      return this
