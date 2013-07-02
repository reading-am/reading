define [
  "support/chai"
  "collections/shared"
  "app/collections/comments"
], (chai, shared, Comments) ->
  chai.should()

  describe "Collection", ->
    describe "Comments", ->

      beforeEach ->
        @collection = new Comments

      shared type: Comments
