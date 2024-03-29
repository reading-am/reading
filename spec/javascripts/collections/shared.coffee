define [
  "support/chai"
  "jquery"
  "underscore"
], (chai, $, _) -> (vals) ->
  chai.should()

  type = vals.type
  methods = vals.methods ? ["create","read","update","destroy"]
  search_term = vals.search_term

  cors_support = $.support.cors

  _.each ["with JSONP", "with JSON"], (v, k) ->

    context v, ->

      before -> $.support.cors = k
      after  -> $.support.cors = cors_support

      if _.include methods, "read"

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

      if search_term

        describe "#search()", ->

          it "should get data from the API", (done) ->
            search = type::search search_term
            search.fetch
              success: (collection, response) ->
                collection.length.should.not.be.empty
                done()
              error: (collection, response) ->
                throw response.responseText.meta.msg
