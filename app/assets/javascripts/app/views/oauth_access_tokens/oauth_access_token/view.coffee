define [
  "app/views/base/model"
  "app/views/oauth_apps/oauth_app/view"
  "text!app/views/oauth_access_tokens/oauth_access_token/styles.css"
  "text!app/views/oauth_access_tokens/oauth_access_token/template.mustache"
], (ModelView, OauthAppView, styles, template) ->

  class OauthAccessTokenView extends ModelView
    @assets
      styles: styles
      template: template

    initialize: ->
      @app_view = new OauthAppView
        model: @model.get("app")

    render: ->
      @$el.html(@template(@json()))
          .append(@app_view.render().el)

      return this
