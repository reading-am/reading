reading.define [
  "backbone"
  "handlebars"
  "app/views/users/users"
], (Backbone, Handlebars, UsersView) ->

  class FollowingersView extends Backbone.View
    template: Handlebars.compile "
      <div id=\"subnav\" class=\"row\">
        <nav class=\"span1\">
          <a href=\"{{user.username}}\">« read</a>
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
    "

    initialize: (options) ->
      @followers = options.followers
      @users_view = new UsersView options

    render: ->
      @$el.html(@template(followers: @followers, user: @model.toJSON()))
      @$el.append(@users_view.render().el)
      return this
