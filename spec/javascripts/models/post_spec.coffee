#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/models/shared"
  "app/models/post"
], (shared, Post) ->

  describe "Model", ->
    describe "Post", ->

      beforeEach ->
        @model = new Post id: 200

      shared
        type: Post
        attrs: {url: "http://www.google.com", title: "Google"}
