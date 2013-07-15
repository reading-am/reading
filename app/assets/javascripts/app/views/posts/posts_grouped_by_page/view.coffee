define [
  "app/views/base/grouped_collection"
  "app/collections/pages"
  "app/views/pages/pages/view"
], (GroupedCollectionView, Pages, PagesView) ->

  class PostsGroupedByPageView extends GroupedCollectionView
    groupBy: "page"
    groupUnder: "posts"
    groupView: PagesView
    groupCollection: Pages
