define [
  "support/chai"
  "collections/shared"
  "app/collections/users"
], (chai, shared, Users) ->
  chai.should()

  describe "Collection", ->
    describe "Users", ->

      beforeEach ->
        @collection = new Users

      shared
        type: Users
        search_term: "greg"
