reading.define "app/collections/pages", [
  "backbone"
  "app"
  "app/models/page"
], (Backbone, App, Page) ->

  class App.Collections.Pages extends Backbone.Collection
    type: "Pages"
    model: Page
