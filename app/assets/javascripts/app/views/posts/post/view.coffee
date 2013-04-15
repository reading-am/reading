define [
  "app/views/base/model"
  "app/views/users/user/view"
  "app/views/pages/page/view"
  "text!app/views/posts/post/template.mustache"
  "text!app/views/posts/post/styles.css"
], (ModelView, UserView, PageView, template, styles) ->

  class PostView extends ModelView
    @assets
      styles: styles
      template: template

    initialize: (options) ->
      @user_view = new UserView model: @model.get("user"), tagName: "div", size: "small"
      @page_view = new PageView model: @model.get("page"), tagName: "div"
      super options

    render: =>
      json = @model.toJSON()
      json.yep = true if @model.get("yn") is true
      json.nope = true if @model.get("yn") is false

      @$el.html(@template(json))
          .find("div:first")
          .append(@user_view.render().el)
          .append(@page_view.render().el)

      return this
