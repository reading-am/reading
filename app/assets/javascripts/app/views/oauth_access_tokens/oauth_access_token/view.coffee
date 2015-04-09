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

    events:
      "click .r_destroy": "destroy"

    initialize: ->
      super
      @app_view = new OauthAppView
        model: @model.get("app")

    destroy: ->
      if confirm "Are you sure you want to revoke access to this application?"
        @model.destroy()

      false

    json: ->
      json = super
      json.created_at = @model.get("created_at").toDateString()
      json

    render: ->
      @$el.html(@template(@json()))
          .prepend(@app_view.render().el)

      return this
