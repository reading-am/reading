define [
  "jquery"
  "app/views/base/model"
  "handlebars"
  "text!app/templates/posts/post_grouped_by_page.hbs"
  "app/models/page" # this needs preloading
], ($, ModelView, Handlebars, template) ->

  class PostGroupedByPageView extends ModelView
    template: Handlebars.compile template

    tagName: "div"
    className: "row w_rule"

    render: =>
      json =
        page:
          title: @model.get("page").get("title")
          excerpt: @model.get("page").get("excerpt")
        user:
          display_name: @model.get("user").get("display_name")
          username: @model.get("user").get("username")

      @$el.append(@template(json))

      return this
