#= require curl_config
#= require libs/curl

reading.curl [
  "app/collections/providers"
], (Providers) ->

  describe "Collection", ->
    describe "Providers", ->

      it "should get some tests written"
