#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "spec/collections/shared"
  "app/collections/pages"
], (shared, Pages) ->

  describe "Collection", ->
    describe "Pages", ->

      beforeEach ->
        @collection = new Pages

      shared()
