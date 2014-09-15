define [
  "app/views/base/model"
  "text!app/views/oauth_apps/form/template.mustache"
  "text!app/views/oauth_apps/form/styles.css"
  "extend/jquery/serialize-object"
], (ModelView, template, styles) ->

  class OauthAppForm extends ModelView
    @assets
      styles: styles
      template: template

    reset: -> @el.reset()
    data: -> @$el.serializeObject()
