define [
  "app/views/base/model"
  "text!app/views/pages/page/template.mustache"
  "text!app/views/pages/page/styles.css"
  "app/models/page" # this has to be loaded here because it's not referenced anywhere else
], (ModelView, template, styles) ->

  class PageView extends ModelView
    @assets
      styles: styles
      template: template

    render: =>
      json = @model.toJSON()
      if @model.posts.length
        json.url = @model.posts.first().get("wrapped_url")

      @$el.html(@template json)
      return this
