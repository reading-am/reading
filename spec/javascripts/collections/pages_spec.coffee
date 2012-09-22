#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/collections/shared"
  "app/collections/pages"
], (shared, Pages) ->

  describe "Collection", ->
    describe "Pages", ->

      beforeEach ->
        @collection = new Pages

      shared
        type: Pages
        search_term: "test"
