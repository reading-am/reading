define [
  "app/views/posts/post"
  "handlebars"
  "app/constants"
  "app/views/users/user"
  "text!app/templates/posts/post_on_page.hbs"
], (PostView, Handlebars, Constants, UserView, template) ->

  class PostOnPageView extends PostView
    template: Handlebars.compile template

    initialize: (options) ->
      @model.on "change", @render, this
      @model.on "remove", @remove

      @user_view = new UserView model: @model.get("user"), size: "small"

    remove: =>
      @$el.slideUp => @$el.remove()

    render: =>
      json = @model.toJSON()
      json.domain = Constants.domain

      @$el.html(@template(json))
          .find(".r_post_bg").prepend(@user_view.render().el)

      return this
