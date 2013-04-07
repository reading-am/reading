define [
  "app/views/base/collection"
  "app/views/pages/page_row/view"
  "app/collections/pages"
  "text!app/views/pages/pages/template.mustache"
], (CollectionView, PageRowView, Pages, template) ->

  class PagesView extends CollectionView
    modelView: PageRowView
    @assets
      template: template

    initialize: (options) ->
      # this takes a posts collection and groups it by Page
      if options.collection.type is "Posts"
        @collection = new Pages
        options.collection.each (post) =>
          @collection.add post.get("page")
          @collection.get(post.get("page").id).posts.add post

      super options
