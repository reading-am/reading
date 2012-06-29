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
        it "should successfully save and delete", (done) ->
          model = new Comment
          model.save {body: "This is a test comment", post_id: 71214, page_id: 1140},
            success: (model, response) ->
              model.get("id").should.be.ok
              model.destroy
                success: (model, response) -> done()
                error: (model, response) -> throw response

            error: (model, response) ->
              throw response

        it "should check to make sure the post belongs to the user", (done) ->
          model = new Comment
          model.save {body: "This is a test comment", post_id: 200, page_id: 91},
            success: (model, response) -> throw response
            error: (model, response) -> done()
