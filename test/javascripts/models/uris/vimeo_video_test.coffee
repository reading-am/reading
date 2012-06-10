#= require curl_config
#= require libs/curl

reading.curl [
  "app/models/uris/vimeo_video"
], (VimeoVideo) ->

  url = "http://vimeo.com/7470754"

  describe "VimeoVideo", ->

    describe "#regex", ->
      it "should successfully identify urls", ->
        VimeoVideo::regex.test(url).should.be.true

    describe "#initialize()", ->
      it "should return the correct id after initialization", ->
        model = new VimeoVideo string: url
        model.get("id").should.equal("7470754")

    describe "#fetch()", ->
      it "should get data from the API", (done) ->
        model = new VimeoVideo string: url
        model.fetch 
          success: (model) ->
            model.get("title").should.equal("HRMI #1")
            done()
          error: (model, response) ->
            throw response.responseText
