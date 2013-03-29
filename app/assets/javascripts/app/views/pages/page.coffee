define [
  "app/views/base/model"
  "mustache"
  "text!app/templates/pages/page.mustache"
  "app/models/page" # this has to be loaded here because it's not referenced anywhere else
], (ModelView, Mustache, template) ->

  class PageView extends ModelView
    template: Mustache.compile template
    className: "r_page"
