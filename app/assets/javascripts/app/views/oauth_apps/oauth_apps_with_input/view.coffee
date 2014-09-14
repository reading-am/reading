define [
  "underscore"
  "jquery"
  "backbone"
  "app/models/user_with_current"
  "app/models/oauth_app"
  "app/views/oauth_apps/oauth_apps/view"
  "text!app/views/oauth_apps/oauth_apps_with_input/template.mustache"
  "text!app/views/oauth_apps/oauth_apps_with_input/styles.css"
  "extend/jquery/serialize-object"
], (_, $, Backbone, User, OauthApp, OauthAppsView, template, styles) ->

  class OauthAppsWithInputView extends Backbone.View
    @assets
      styles: styles
      template: template

    events:
      "click .r_create": "toggle_input"
      "click .r_cancel": "toggle_input"
      "submit form": "submit"

    initialize: (options) ->
      @subview = new OauthAppsView collection: @collection
      @user = options.user

    toggle_input: ->
      @$(".r_create").toggle()
      @form.toggle()[0].reset()
      false

    submit: ->
      app = new OauthApp @form.serializeObject().app
      app.set "user", @user

      if app.isValid()
        @subview.collection.create app
        @toggle_input()

      false

    render: ->
      @$el.html(@template({signed_in: User::current.signed_in()}))
          .prepend(@subview.render().el)

      @form = @$("form")

      return this
