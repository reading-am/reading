define [
  "app/views/base/collection"
  "app/views/posts/post_grouped_by_page"
], (CollectionView, PostGroupedByPageView) ->

  class PostsGroupedByPageView extends CollectionView
    modelView: PostGroupedByPageView

    tagName: "div"
