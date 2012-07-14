reading.define [
  "backbone"
  "app/init"
  "app/models/page"
], (Backbone, App, Page) ->

  class App.Collections.Pages extends Backbone.Collection
    type: "Pages"
    model: Page
