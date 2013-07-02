define [
  "support/chai"
  "models/shared"
  "app/models/user"
  "app/collections/users"
], (chai, shared, User, Users) ->
  chai.should()

  describe "Model", ->
    describe "User", ->

      beforeEach ->
        @model = new User id: 2

      shared
        methods: ["read"]
        type: User
