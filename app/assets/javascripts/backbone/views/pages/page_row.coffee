define [
  "jquery"
  "app/views/base/model"
  "mustache"
  "app/views/pages/page"
  "app/views/posts/subposts"
  "app/collections/posts"
  "text!app/templates/pages/page_row.mustache"
  "app/models/page" # this needs preloading
], ($, ModelView, Mustache, PageView, SubPostsView, Posts, template) ->

  class PageRowView extends ModelView
    template: Mustache.compile template

    tagName: "div"
    className: "row w_rule"

    initialize: ->
      @page_view = new PageView model: @model, tagName: "div"
      @posts_view = new SubPostsView collection: @model.posts

    render: =>
      @$el.append(@template())
      @$(".posts_group")
        .append(@page_view.render().el)
        .append(@posts_view.render().el)

      return this
