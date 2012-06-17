reading.define "test/models/shared", ["jquery"], ($) -> ->

  describe "#fetch()", ->

    if $.support.cors

      context "with CORS", ->

        it "should get data from the API", (done) ->
          @model.fetch 
            success: (model, response) ->
              model.get("created_at").should.exist
              done()
            error: (model, response) ->
              throw response.responseText.meta.msg

        it "should throw a 404 for a nonexistent entity", (done) ->
          @model.set("id", "should_not_exist", silent: true)
          @model.fetch 
            success: (model, response) ->
              throw response.responseText.meta.msg
            error: (model, response) ->
              done()

    context "without CORS", ->

      # turn off cors support
      cors_support = $.support.cors
      $.support.cors = false

      it "should get data from the API", (done) ->
        @model.fetch 
          success: (model, response) ->
            model.get("created_at").should.exist
            done()
          error: (model, response) ->
            throw response.responseText.meta.msg

      it "should throw a 404 for a nonexistent entity", (done) ->
        @model.set("id", "should_not_exist", silent: true)
        @model.fetch 
          success: (model, response) ->
            throw response.responseText.meta.msg
          error: (model, response) ->
            done()

      $.support.cors = cors_support
