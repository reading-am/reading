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
        methods: [] # we don't list all users via the API
        search_term: "greg"
