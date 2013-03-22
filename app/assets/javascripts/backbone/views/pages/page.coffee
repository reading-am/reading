define [
  "app/views/base/model"
  "mustache"
  "text!app/templates/pages/page.hbs"
  "app/models/page" # this has to be loaded here because it's not referenced anywhere else
], (ModelView, Handlebars, template) ->

  class PageView extends ModelView
    template: Handlebars.compile template
    className: "r_page"
