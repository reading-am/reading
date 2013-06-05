define [
  "app/views/base/collection"
  "app/collections/pages"
  "app/views/pages/pages/view"
], (CollectionView, Pages, PagesView) ->

  class PostsGroupedByPageView extends CollectionView
    initialize: (options) ->
      pages = new Pages
      @collection.each (post) =>
        pages.add post.get("page")
        pages.get(post.get("page").id).posts.add post

      @subview = new PagesView collection: pages
      @setElement @subview.el

      super options

    addOne: (post) ->
      @subview.collection.add(post.get("page"))
      @subview.collection.get(post.get("page").id).posts.add post

    render: ->
      @subview.render()
      return this
