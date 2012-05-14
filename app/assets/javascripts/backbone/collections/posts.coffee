define ["backbone","backbone/models/post"], (Backbone, Post) ->

  class Posts extends Backbone.Collection
    type: "Posts"
    model: Post
