#= require curl_config
#= require libs/curl
#= require ./shared_helper

reading.curl [
  "app/models/page"
], (Page) ->

  describe "Model", ->
    describe "Page", ->

      beforeEach ->
        @model = new Page id: 201

      shared()
