define [
  "support/chai"
  "models/uris/shared"
  "app/models/uris/vimeo_video"
], (chai, shared, VimeoVideo) ->
  chai.should()

  describe "Model", ->
    describe "URI", ->
      describe "VimeoVideo", ->

        beforeEach ->
          @id = "7470754"
          @urls = [
            "http://vimeo.com/#{@id}"
            "http://vimeo.com/31809461"
          ]
          @model = new VimeoVideo string: @urls[0]

        shared()

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            @model.get("id").should.equal(@id)

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            @model.fetch 
              success: (model, response) ->
                model.get("title").should.equal("HRMI #1")
                done()
              error: (model, response) ->
                throw response.responseText
