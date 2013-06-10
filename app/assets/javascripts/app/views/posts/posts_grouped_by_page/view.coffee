define [
  "app/views/base/collection"
  "app/collections/pages"
  "app/views/pages/pages/view"
], (CollectionView, Pages, PagesView) ->

  class PostsGroupedByPageView extends CollectionView
    initialize: (options) ->
      pages = new Pages
      @collection.each (post) =>
        post.get("page").posts.add post
        pages.add post.get("page")

      @subview = new PagesView collection: pages
      @setElement @subview.el

      super options

    addOne: (post) ->
      # the post must be added to the page first in order that
      # the wrapped url is used to render the page
      post.get("page").posts.add post
      @subview.collection.add(post.get("page"))

    render: ->
      @subview.render()
      return this
