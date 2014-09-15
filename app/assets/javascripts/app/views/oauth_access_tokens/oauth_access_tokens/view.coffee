define [
  "app/views/base/collection/view"
  "app/views/oauth_access_tokens/oauth_access_token/view"
  "text!app/views/oauth_access_tokens/oauth_access_tokens/styles.css"
  "text!app/views/oauth_access_tokens/oauth_access_tokens/template.mustache"
], (CollectionView, OauthAccessTokenView, styles, template) ->

  class OauthAccessTokensView extends CollectionView
    @assets
      styles: styles
      template: template

    modelView: OauthAccessTokenView
    empty_msg: "You don't have any apps yet"
