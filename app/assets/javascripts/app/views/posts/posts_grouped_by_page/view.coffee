define [
  "underscore"
  "app/models/user_with_current"
  "app/views/base/grouped_collection"
  "app/collections/pages"
  "app/views/pages/pages/view"
], (_, User, GroupedCollectionView, Pages, PagesView) ->

  class PostsGroupedByPageView extends GroupedCollectionView
    groupBy: "page"
    groupUnder: "posts"
    groupView: PagesView
    groupCollection: Pages

    initialize: (options) ->
      super
      @collection.on "sync", (col, resp)  =>
        @populate_follow_state _.map(resp.posts, (post) -> post.get("page").id)
      @collection.on "reset", (col, opt)  =>
        @populate_follow_state col.map((post) -> post.get("page").id)

    populate_follow_state: (ids) ->
      # if there are users in the collection and,
      # if there's only one user, it's not the current user
      if User::current.signed_in()
        User::current.posts.params =
          limit: ids.length
          page_ids: ids
        User::current.posts.fetch success: (posts) =>
          posts.each (post) => @subview.collection.get(post.get("page")).set has_posted: true
