reading.define "test/models/shared", ["jquery","underscore"], ($,_) -> ->

  @methods ?= ["create","read","update","destroy"]
  cors_support = $.support.cors

  $.each ["with JSONP", "with JSON"], (k, v) ->

    context v, ->

      before -> $.support.cors = k
      after  -> $.support.cors = cors_support

      if _.include @methods, "read"

        describe "#fetch()", ->

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

      if _.include @methods, "create"

        describe "#save()", ->

          it "should successfully save and delete", (done) ->
            model = new @type
            model.save @attrs,
              success: (model, response) ->
                model.get("id").should.be.ok

                if _.include @methods, "destroy"
                  model.destroy
                    success: (model, response) -> done()
                    error: (model, response) -> throw response
                else
                  done()

              error: (model, response) ->
                throw response

          it "should successfully update"
