#= require curl_config
#= require libs/curl

reading.curl [
  "app/models/comment"
], (Comment) ->

  id = "333"

  describe "Comment", ->

    describe "#fetch()", ->
      it "should get data from the API", (done) ->
        model = new Comment id: id
        model.fetch 
          success: (model) ->
            model.get("description").should.equal("Reading Message Server")
            done()
          error: (model, response) ->
            throw response.responseText.data.message
