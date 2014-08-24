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
        @populate_follow_state _.map(resp.posts, (post) -> post.page.id)
      @collection.on "reset", (col, opt)  =>
        @populate_follow_state col.map((post) -> post.get("page").id)

    populate_follow_state: (ids) ->
      if User::current.signed_in()
        known_ids = @collection.filter((post) ->
          post.get("user").id is User::current.id
        ).map (post) ->
          post.get("page").id
        unknown_ids = _.difference ids, known_ids

        if unknown_ids.length
          User::current.posts.params =
            limit: unknown_ids.length
            page_ids: unknown_ids
          User::current.posts.fetch success: (posts) => @collection.add(posts)
