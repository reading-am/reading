#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "test/models/shared"
  "app/models/comment"
], (shared, Comment) ->

  describe "Model", ->
    describe "Comment", ->

      beforeEach ->
        @model = new Comment id: 200

      shared()

      describe "#save()", ->
        it "should successfully save", (done) ->
          model = new Comment
          model.save {body: "This is a test comment", page_id: 200},
            success: (model, response) ->
              model.get("id").should.be.ok
              done()
            error: (model, response) ->
              throw response
