define [
  "app/views/base/grouped_collection"
  "app/collections/pages"
  "app/views/pages/pages/view"
], (GroupedCollectionView, Pages, PagesView) ->

  class PostsGroupedByPageView extends GroupedCollectionView
    group_by: "page"
    group_under: "posts"
    group_view: PagesView
    group_collection: Pages
