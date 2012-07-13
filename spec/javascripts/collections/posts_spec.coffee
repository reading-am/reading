#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "spec/collections/shared"
  "app/collections/posts"
], (shared, Posts) ->

  describe "Collection", ->
    describe "Posts", ->

      beforeEach ->
        @collection = new Posts

      shared type: Posts
