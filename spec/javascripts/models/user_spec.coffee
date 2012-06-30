#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "spec/models/shared"
  "app/models/user"
  "app/collections/users"
], (shared, User, Users) ->

  describe "Model", ->
    describe "User", ->

      model = new User id: 2

      shared
        methods: ["read"]
        type: User
        model: model
