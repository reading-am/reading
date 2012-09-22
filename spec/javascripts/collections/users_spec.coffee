#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/collections/shared"
  "app/collections/users"
], (shared, Users) ->

  describe "Collection", ->
    describe "Users", ->

      beforeEach ->
        @collection = new Users

      shared
        type: Users
        search_term: "greg"
