#= require curl_config
#= require libs/curl

reading.curl [
  "app/models/provider"
], (Provider) ->

  describe "Model", ->
    describe "Provider", ->

      it "should get some tests written", ->
