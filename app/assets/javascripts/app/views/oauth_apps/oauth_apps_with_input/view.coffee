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
      "click .r_create": "toggle_input"
      "click .r_cancel": "toggle_input"
      "submit form": "submit"

    initialize: (options) ->
      @subview = new OauthAppsView collection: @collection
      @form_view = new OauthAppFormView model: new OauthApp owner: options.owner

    toggle_input: ->
      @$(".r_create").toggle()
      @form_view.$el.toggle()
      @form_view.reset()
      false

    submit: ->
      @form_view.set_data()
      if @form_view.model.isValid()
        @subview.collection.create @form_view.model
        @toggle_input()

      false

    render: ->
      @$el.html(@template({signed_in: User::current.signed_in()}))
          .prepend(@subview.render().el)
          .find(".r_create").after(@form_view.render().el)

      return this
