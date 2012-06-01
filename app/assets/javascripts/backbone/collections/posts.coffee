reading.define [
  "backbone"
  "app"
  "app/models/post"
], (Backbone, App, Post) ->

  class App.Collections.Posts extends Backbone.Collection
    type: "Posts"
    model: Post
