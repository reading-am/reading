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
      json = @model.toJSON(false)

      json.yep = @model.get("yn") is true
      json.nope = @model.get("yn") is false
      json.user.is_current = is_current_user
      json.user.display_name = if is_current_user then "You" else @model.get("user").get("display_name")

      @$el.append(@template(json))

      return this
