define [
  "underscore"
  "app/views/base/grouped_collection"
  "app/collections/users"
  "app/views/users/users_with_posts/view"
  "text!app/views/posts/posts_grouped_by_user/template.mustache"
  "text!app/views/posts/posts_grouped_by_user/styles.css"
], (_, GroupedCollectionView, Users, UsersWithPostsView, template, styles) ->

  class PostsGroupedByUserView extends GroupedCollectionView
    @assets
      styles: styles
      template: template

    groupBy: "user"
    groupUnder: "posts"
    groupView: UsersWithPostsView
    groupCollection: Users

    is_online:  (ids, state) ->
      @subview.collection.setEach ids, status_online: state

    is_blurred: (ids, state) ->
      @subview.collection.setEach ids, status_blurred: state

    is_typing:  (ids, state) ->
      @subview.collection.setEach ids, status_typing: state
