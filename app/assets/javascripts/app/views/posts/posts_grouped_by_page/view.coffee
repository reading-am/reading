define [
  "app/views/base/grouped_collection"
  "app/collections/pages"
  "app/views/pages/pages/view"
], (GroupedCollectionView, Pages, PagesView) ->

  class PostsGroupedByPageView extends GroupedCollectionView
    group_by: "page"
    group_under: "posts"

    initialize: (options) ->
      @subview = new PagesView collection: new Pages
      super options
