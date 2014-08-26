define [
  "backbone"
  "app/init"
  "app/models/page"
], (Backbone, App, Page) ->

  class App.Collections.Pages extends Backbone.Collection
    type: "Pages"
    model: Page

    comparator: (page) ->
      -(page.posts.first()?.get("created_at") ||
        page.get("created_at") ||
        new Date)
