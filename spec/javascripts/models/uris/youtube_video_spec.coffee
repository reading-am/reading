define [
  "support/chai"
  "underscore"
  "models/uris/shared"
  "app/models/uris/youtube_video"
], (chai, _, shared, YouTubeVideo) ->
  chai.should()

  describe "Model", ->
    describe "URI", ->
      describe "YouTubeVideo", ->

        beforeEach ->
          @id = "7_aJHJdCHAo"
          @urls = [
            "http://www.youtube.com/watch?v=#{@id}"
            "http://youtu.be/#{@id}"
          ]
          @model = new YouTubeVideo string: @urls[0]

        shared()

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            @model.get("id").should.equal(@id)

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            @model.fetch 
              success: (model, response) ->
                model.get("entry").should.exist
                done()
              error: (model, response) ->
                throw response.responseText
