define [
  "underscore"
  "jquery"
  "backbone"
  "app/models/user_with_current"
  "app/models/oauth_app"
  "app/views/oauth_apps/oauth_apps/view"
  "app/views/oauth_apps/form/view"
  "text!app/views/oauth_apps/oauth_apps_with_input/template.mustache"
  "text!app/views/oauth_apps/oauth_apps_with_input/styles.css"
], (_, $, Backbone, User, OauthApp, OauthAppsView, OauthAppFormView, template, styles) ->

  class OauthAppsWithInputView extends Backbone.View
    @assets
      styles: styles
      template: template

    events:
      "click .r_create": "create"
      "click .r_cancel": "cancel"
      "submit form": "submit"

    initialize: (options) ->
      @subview = new OauthAppsView collection: @collection

    create: ->
      @form_view = new OauthAppFormView model: new OauthApp
      @$("#new_app").html @form_view.render().el
      false

    cancel: ->
      @render()
      false

    submit: ->
      @form_view.model.set @form_view.data()
      if @form_view.model.isValid()
        @subview.collection.create @form_view.model
        @render()

      false

    render: ->
      @$el.html(@template({signed_in: User::current.signed_in()}))
          .prepend(@subview.render().el)

      return this
