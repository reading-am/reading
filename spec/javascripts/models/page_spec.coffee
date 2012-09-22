#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/models/shared"
  "app/models/page"
], (shared, Page) ->

  describe "Model", ->
    describe "Page", ->

      beforeEach ->
        @model = new Page id: 1140

      shared
        methods: ["read"]
        type: Page
