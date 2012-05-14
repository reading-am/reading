define ["backbone","backbone/models/page"], (Backbone, Page) ->

  class Pages extends Backbone.Collection
    type: "Pages"
    model: Page
