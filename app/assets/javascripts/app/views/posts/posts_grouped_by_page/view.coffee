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
        curr_posts = @collection.filter((post) -> post.get("user").id is User.prototype.current.id)
        _.each curr_posts, (post) => @subview.collection.get(post.get("page")).set post: post
        
        known_ids = curr_posts.map (post) -> post.get("page").id
        unknown_ids = _.filter ids, (id) -> known_ids.indexOf(id) is -1

        if unknown_ids.length
          User::current.posts.params =
            limit: ids.length
            page_ids: unknown_ids
          User::current.posts.fetch success: (posts) =>
            posts.each (post) => @subview.collection.get(post.get("page")).set post: post
