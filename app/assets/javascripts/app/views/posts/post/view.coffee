define [
  "underscore"
  "jquery"
  "app/views/base/model"
  "app/views/users/user/view"
  "app/views/pages/page/view"
  "text!app/views/posts/post/template.mustache"
  "text!app/views/posts/post/styles.css"
], (_, $, ModelView, UserView, PageView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class PostView extends ModelView
    @parse_template template

    initialize: (options) ->
      load_css()

      @user_view = new UserView model: @model.get("user"), tagName: "div", size: "small"
      @page_view = new PageView model: @model.get("page"), tagName: "div"
      super()

    render: =>
      json = @model.toJSON()
      json.yep = true if @model.get("yn") is true
      json.nope = true if @model.get("yn") is false

      @$el.html(@template(json))
          .find("div:first")
          .append(@user_view.render().el)
          .append(@page_view.render().el)

      return this
