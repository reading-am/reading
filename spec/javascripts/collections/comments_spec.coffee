#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/collections/shared"
  "app/collections/comments"
], (shared, Comments) ->

  describe "Collection", ->
    describe "Comments", ->

      beforeEach ->
        @collection = new Comments

      shared type: Comments
