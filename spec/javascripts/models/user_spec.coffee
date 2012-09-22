#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/models/shared"
  "app/models/user"
  "app/collections/users"
], (shared, User, Users) ->

  describe "Model", ->
    describe "User", ->

      beforeEach ->
        @model = new User id: 2

      shared
        methods: ["read"]
        type: User
