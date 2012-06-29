#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "test/models/shared"
  "app/models/page"
], (shared, Page) ->

  describe "Model", ->
    describe "Page", ->

      beforeEach ->
        @methods = ["read"]
        @model = new Page id: 201

      shared()
