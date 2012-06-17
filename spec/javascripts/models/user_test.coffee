#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "test/models/shared"
  "app/models/user"
], (shared, User) ->

  describe "Model", ->
    describe "User", ->

      beforeEach ->
        @model = new User id: 201

      shared()
