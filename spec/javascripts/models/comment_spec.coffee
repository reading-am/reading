#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/models/shared"
  "app/models/comment"
], (shared, Comment) ->

  describe "Model", ->
    describe "Comment", ->

      beforeEach ->
        @model = new Comment id: 200

      shared
        type: Comment
        attrs: {body: "This is a test comment", post_id: 95087, page_id: 1140}

      describe "#save()", ->

        it "should check to make sure the post belongs to the user", (done) ->
          model = new Comment
          model.save {body: "This is a test comment", post_id: 201, page_id: 91},
            success: (model, response) -> throw response
            error: (model, response) -> done()

      describe "#is_a_show()", ->

        it "should recognize a single 'show'", ->
          model = new Comment body: "@greg"
          model.is_a_show().should.be.true

        it "should recognize a multiple 'show'", ->
          model = new Comment body: "@greg   \t\n @howard,@foxhole , @richard"
          model.is_a_show().should.be.true
