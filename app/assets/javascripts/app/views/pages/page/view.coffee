define [
  "app/views/base/model"
  "text!app/views/pages/page/template.mustache"
  "text!app/views/pages/page/styles.css"
  "app/models/page" # this has to be loaded here because it's not referenced anywhere else
], (ModelView, template, styles) ->

  class PageView extends ModelView
    @assets
      template: template
      styles: styles