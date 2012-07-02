#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "spec/collections/shared"
  "app/collections/users"
], (shared, Users) ->

  describe "Collection", ->
    describe "Users", ->

      beforeEach ->
        @collection = new Users

      shared()
