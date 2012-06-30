reading.define "spec/collections/shared", ["jquery"], ($) -> ->

  cors_support = $.support.cors

  describe "#fetch()", ->

    $.each ["with JSONP", "with JSON"], (k, v) ->

      context v, ->

        before -> $.support.cors = k
        after  -> $.support.cors = cors_support

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
