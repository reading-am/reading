reading.define "spec/models/shared", [
  "jquery"
  "underscore"
], ($, _) -> (vals) ->

  methods = vals.methods ? ["create","read","update","destroy"]
  type = vals.type
  attrs = vals.attrs

  test_model = new type

  cors_support = $.support.cors

  _.each ["with JSONP", "with JSON"], (v, k) ->

    context v, ->

      before -> $.support.cors = k
      after  -> $.support.cors = cors_support

      if _.include methods, "read"

        describe "#fetch()", ->

          it "should get data from the API", (done) ->
            @model.fetch
              success: (model, response) ->
                model.get("created_at").should.exist
                done()
              error: (model, response) ->
                throw response.responseText.meta.msg

          it "should throw a 404 for a nonexistent entity", (done) ->
            missing = new type id: "should_not_exist"
            missing.fetch
              success: (model, response) ->
                throw response.responseText.meta.msg
              error: (model, response) ->
                done()

        if test_model._has_many? then context "Has Many", ->

          _.each test_model._has_many, (v) ->

            describe "##{v}()", (done) ->

              it "should get data from the API", (done) ->

                @model[v].fetch
                  success: (collection, response) ->
                    collection.length.should.not.be.empty
                    done()
                  error: (collection, response) ->
                    throw response.responseText.meta.msg

      if _.include methods, "create"

        describe "#save()", ->

          it "should successfully save and delete", (done) ->
            new_model = new type
            new_model.save attrs,
              success: (model, response) ->
                model.get("id").should.be.ok

                if _.include methods, "destroy"
                  model.destroy
                    success: (model, response) -> done()
                    error: (model, response) -> throw response
                else
                  done()

              error: (model, response) ->
                throw response

          it "should successfully update"
