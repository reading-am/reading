define [
  "jquery"
  "app/views/base/model"
  "handlebars"
  "app/models/current_user"
  "text!app/templates/posts/post_grouped_by_page.hbs"
  "app/models/page" # this needs preloading
], ($, ModelView, Handlebars, current_user, template) ->

  class PostGroupedByPageView extends ModelView
    template: Handlebars.compile template

    tagName: "div"
    className: "row w_rule"

    render: =>
      is_current_user = @model.get("user").get("id") is current_user.get("id")
      json =
        page:
          title: @model.get("page").get("title")
          excerpt: @model.get("page").get("excerpt")
        user:
          is_current_user: if is_current_user then 1 else 0
          display_name: if is_current_user then "You" else @model.get("user").get("display_name")
          username: @model.get("user").get("username")

      @$el.append(@template(json))

      return this
