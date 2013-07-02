define [
  "support/chai"
  "underscore"
  "models/uris/shared"
  "app/models/uris/instagram_image"
], (chai, _, shared, InstagramImage) ->
  chai.should()

  describe "Model", ->
    describe "URI", ->
      describe "InstagramImage", ->

        beforeEach ->
          @ids = [
            "Lq8xzYBvXC"
            "LmGhlTMo88"
            "XgS1tuPf3l"
          ]
          @urls = [
            "http://instagr.am/p/#{@ids[0]}/"
            "http://instagr.am/p/#{@ids[1]}"
            "http://instagram.com/p/#{@ids[2]}"
          ]
          @models = _.map @urls, (url) -> new InstagramImage(string: url)
          @model = @models[0]

        shared()

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            _.each @models, (model, i) =>
              model.get("id").should.equal(@ids[i])

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            @model.fetch 
              success: (model, response) ->
                model.get("title").should.equal("Mint Julip in Louisville.")
                done()
              error: (model, response) ->
                throw response.responseText
