reading.define "test/collections/shared", -> ->

  describe "#fetch()", ->
    it "should get data from the API", (done) ->
      @collection.fetch
        success: (collection, response) ->
          collection.length.should.not.be.empty
          done()
        error: (collection, response) ->
          throw response.responseText.meta.msg
    it "should factory JSON from API", (done) ->
      @collection.fetch
        success: (collection, response) ->
          collection.first().should.be.instanceof(collection.model)
          done()
        error: (collection, response) ->
          throw response.responseText.meta.msg
