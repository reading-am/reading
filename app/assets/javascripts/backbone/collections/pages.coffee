define [
  "backbone"
  "app/init"
  "app/models/page"
], (Backbone, App, Page) ->

  class App.Collections.Pages extends Backbone.Collection
    type: "Pages"
    model: Page

    comparator: (page) ->
      if page.posts.first()?
        time = page.posts.first().get("updated_at").getTime()
      else if page.get("updated_at")?
        time = page.get("updated_at").getTime()
      else
        # 999... is a hack so that the first new page
        # without an id will appear at the top
        time = 9999999999

      return -time
