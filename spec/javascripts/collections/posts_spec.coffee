#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/collections/shared"
  "app/collections/posts"
], (shared, Posts) ->

  describe "Collection", ->
    describe "Posts", ->

      beforeEach ->
        @collection = new Posts

      shared type: Posts
