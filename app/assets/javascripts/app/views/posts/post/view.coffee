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

    set_yn: =>
      # reset for re-renders on update
      @$el.removeClass("r_yep r_nope")

      if @model.get("yn") is true
        @$el.addClass("r_yep")
      else if @model.get("yn") is false
        @$el.addClass("r_nope")

    render: =>
      @set_yn()

      @$el.append(@user_view.render().el)
      @$el.append(@page_view.render().el)

      return this
