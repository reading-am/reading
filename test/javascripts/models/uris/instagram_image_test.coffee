#= require curl_config
#= require libs/curl

reading.curl [
  "app/models/uris/instagram_image"
], (InstagramImage) ->

  url = "http://instagr.am/p/Lq8xzYBvXC/"

  describe "Model", ->
    describe "URI", ->
      describe "InstagramImage", ->

        describe "#regex", ->
          it "should successfully identify urls", ->
            InstagramImage::regex.test(url).should.be.true

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            model = new InstagramImage string: url
            model.get("id").should.equal("Lq8xzYBvXC")

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            model = new InstagramImage string: url
            model.fetch 
              success: (model) ->
                model.get("title").should.equal("Mint Julip in Louisville.")
                done()
              error: (model, response) ->
                throw response.responseText
