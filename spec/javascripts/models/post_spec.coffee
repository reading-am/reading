define [
  "support/chai"
  "models/shared"
  "app/models/post"
], (chai, shared, Post) ->
  chai.should()

  describe "Model", ->
    describe "Post", ->

      beforeEach ->
        @model = new Post id: 200

      shared
        type: Post
        attrs: {url: "http://www.google.com", title: "Google"}
