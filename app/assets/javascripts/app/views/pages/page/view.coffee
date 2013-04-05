define [
  "app/views/base/model"
  "text!app/views/pages/page/template.mustache"
  "text!app/views/pages/page/styles.css"
  "app/models/page" # this has to be loaded here because it's not referenced anywhere else
], (ModelView, template) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class PageView extends ModelView
    @parse_template template

    initialize: (options) ->
      load_css()
      super options
