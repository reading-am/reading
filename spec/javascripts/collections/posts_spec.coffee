define [
  "support/chai"
  "collections/shared"
  "app/collections/posts"
], (chai, shared, Posts) ->
  chai.should()

  describe "Collection", ->
    describe "Posts", ->

      beforeEach ->
        @collection = new Posts

      shared type: Posts
