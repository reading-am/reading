define [
  "jquery"
  "app/views/base/model"
  "handlebars"
  "app/views/pages/page"
  "app/views/posts/subposts"
  "app/collections/posts"
  "text!app/templates/pages/page_row.hbs"
  "app/models/page" # this needs preloading
], ($, ModelView, Handlebars, PageView, SubPostsView, Posts, template) ->

  class PageRowView extends ModelView
    template: Handlebars.compile template

    tagName: "div"
    className: "row w_rule"

    initialize: ->
      @page_view = new PageView model: @model.get("page"), tagName: "div"
      @posts_view = new SubPostsView collection: new Posts [@model]

    render: =>
      @$el.append(@template())
      @$(".posts_group")
        .append(@page_view.render().el)
        .append(@posts_view.render().el)

      return this
