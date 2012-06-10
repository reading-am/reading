#= require curl_config
#= require libs/curl

reading.curl [
  "underscore"
  "app/models/uris/youtube_video"
], (_, YouTubeVideo) ->

  id = "7_aJHJdCHAo"
  urls = [
    "http://www.youtube.com/watch?v=#{id}"
    "http://youtu.be/#{id}"
  ]

  describe "Model", ->
    describe "URI", ->
      describe "YouTubeVideo", ->

        describe "#regex", ->
          it "should successfully identify urls", ->
            _.each urls, (url) ->
              YouTubeVideo::regex.test(url).should.be.true

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            model = new YouTubeVideo string: urls[0]
            model.get("id").should.equal(id)

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            model = new YouTubeVideo string: urls[0]
            model.fetch 
              success: (model) ->
                model.get("entry").should.exist
                done()
              error: (model, response) ->
                throw response.responseText
