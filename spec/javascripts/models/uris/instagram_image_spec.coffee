#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/models/uris/shared"
  "app/models/uris/instagram_image"
], (shared, InstagramImage) ->

  describe "Model", ->
    describe "URI", ->
      describe "InstagramImage", ->

        beforeEach ->
          @id = "Lq8xzYBvXC"
          @urls = [
            "http://instagr.am/p/#{@id}/"
            "http://instagr.am/p/LmGhlTMo88"
          ]
          @model = new InstagramImage string: @urls[0]

        shared() 

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            @model.get("id").should.equal(@id)

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            @model.fetch 
              success: (model, response) ->
                model.get("title").should.equal("Mint Julip in Louisville.")
                done()
              error: (model, response) ->
                throw response.responseText
