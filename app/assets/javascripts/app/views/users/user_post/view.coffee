define [
  "app/views/posts/post_on_page/view"
], (PostOnPageView) ->

  class UserPost extends PostOnPageView

    initialize: (options) ->
      @model = @model.posts.first()
      super
