window.shared = ->

  describe "#fetch()", ->
    it "should get data from the API", (done) ->
      @model.fetch 
        success: (model, response) ->
          model.get("body").should.equal("me me me")
          done()
        error: (model, response) ->
          throw response.responseText.meta.msg

    it "should throw a 404 for a nonexistent entity", (done) ->
      @model.fetch 
        success: (model, response) ->
          throw response.responseText.meta.msg
        error: (model, response) ->
          done()
