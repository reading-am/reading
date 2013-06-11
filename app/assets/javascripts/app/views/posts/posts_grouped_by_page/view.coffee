define [
  "app/views/base/collection"
  "app/collections/pages"
  "app/views/pages/pages/view"
], (CollectionView, Pages, PagesView) ->

  class PostsGroupedByPageView extends CollectionView
    initialize: (options) ->
      pages = new Pages
      @collection.each (post) => @groupUnder(post, pages)

      @subview = new PagesView collection: pages
      @setElement @subview.el

      super options

    addOne: (post) ->
      @groupUnder post, @subview.collection

    groupUnder: (post, pages) ->
      page = pages.get(post.get("page").id)
      if page
        page.posts.add post
      else
        post.get("page").posts.add post
        pages.add(post.get("page"))

    render: ->
      @subview.render()
      return this
