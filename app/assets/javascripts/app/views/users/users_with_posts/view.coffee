define [
  "app/views/users/users/view"
  "app/views/posts/post_on_page/view"
], (UsersView, PostOnPageView) ->

  class UsersWithPosts extends UsersView
    modelView: PostOnPageView
