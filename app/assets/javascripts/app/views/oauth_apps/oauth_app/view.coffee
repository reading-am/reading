define [
  "app/views/base/model"
  "app/models/oauth_app"
  "app/views/oauth_apps/form/view"
  "text!app/views/oauth_apps/oauth_app/styles.css"
  "text!app/views/oauth_apps/oauth_app/template.mustache"
], (ModelView, OauthApp, OauthAppFormView, styles, template) ->

  class OauthAppView extends ModelView
    @assets
      styles: styles
      template: template

    events:
      "click .r_secret": "show_secret"
      "click .r_edit": "edit"
      "click .r_cancel": "render"
      "click .r_destroy": "destroy"

    show_secret: ->
      @$(".r_secret code").text @model.get("consumer_secret")
      false

    edit: ->
      @form_view = new OauthAppFormView model: @model
      @$el.html @form_view.render().el

    destroy: ->
      if confirm "Are you sure you want to delete this app? All users will instantly lose access and you can't undo this."
        @model.destroy()

      false

    remove: ->
      @$el.slideUp => @$el.remove()

    json: ->
      json = super
      json.consumer_secret = "Click to show" #if json.consumer_secret
      json
