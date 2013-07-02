define [
  "support/chai"
  "collections/shared"
  "app/collections/pages"
], (chai, shared, Pages) ->
  chai.should()

  describe "Collection", ->
    describe "Pages", ->

      beforeEach ->
        @collection = new Pages

      shared
        type: Pages
        search_term: "test"
