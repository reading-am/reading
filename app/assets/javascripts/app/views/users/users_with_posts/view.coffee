define [
  "app/views/users/users/view"
  "app/views/users/user_post/view"
], (UsersView, UserPostView) ->

  class UsersWithPosts extends UsersView
    modelView: UserPostView
