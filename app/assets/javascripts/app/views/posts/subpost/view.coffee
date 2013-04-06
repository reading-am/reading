define [
  "app/views/posts/post_on_page/view"
  "app/views/users/user/view"
  "text!app/views/posts/subpost/template.mustache"
  "text!app/views/posts/subpost/styles.css"
], (PostOnPageView, UserView, template, styles) ->

  class SubPostView extends PostOnPageView
    @assets
      styles: styles
      template: template

    initialize: (options) ->
      if @model.get("referrer_post").get("user").get("id")
        @ref_user_view = new UserView
          model: @model.get("referrer_post").get("user")
          size: "small"

      super options

    render: =>
      super()

      if @ref_user_view?
        @$el.find(".r_post_bg").append @ref_user_view.render().$el.prepend("because of ")

      return this
