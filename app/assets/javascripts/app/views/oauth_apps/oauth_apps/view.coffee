define [
  "app/views/base/collection/view"
  "app/views/oauth_apps/oauth_app/view"
  "text!app/views/oauth_apps/oauth_apps/styles.css"
  "text!app/views/oauth_apps/oauth_apps/template.mustache"
], (CollectionView, OauthAppView, styles, template) ->

  class OauthAppsView extends CollectionView
    @assets
      styles: styles
      template: template

    modelView: OauthAppView
    empty_msg: "You don't have any apps yet"
