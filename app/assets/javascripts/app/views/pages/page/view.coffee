define [
  "app/views/base/model"
  "text!app/views/pages/page/template.mustache"
  "app/models/page" # this has to be loaded here because it's not referenced anywhere else
], (ModelView, template) ->

  class PageView extends ModelView
    @parse_template template
