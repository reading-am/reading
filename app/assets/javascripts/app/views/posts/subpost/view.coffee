define [
  "app/models/user_with_current"
  "app/views/posts/post_on_page/view"
  "app/views/users/user/view"
  "text!app/views/posts/subpost/template.mustache"
  "text!app/views/posts/subpost/styles.css"
], (User, PostOnPageView, UserView, template, styles) ->

  class SubPostView extends PostOnPageView
    @assets
      styles: styles
      template: template

    events:
      "click .r_destroy": "destroy"

    initialize: (options) ->
      if @model.get("referrer_post").get("user").get("id")
        @ref_user_view = new UserView
          model: @model.get("referrer_post").get("user")
          size: "small"

      super options

    destroy: ->
      if confirm "Are you sure you want to delete this post?"
        @model.destroy()

      false

    json: ->
      json = super()
      json.page = verb: @model.get("page").verb()
      json.is_owner = (@model.get("user").get("id") == User::current.get("id"))
      return json

    render: ->
      super()

      if @ref_user_view?
        @$el.find(".r_post_bg")
          .append(" because of ")
          .append(@ref_user_view.render().el)

      return this
