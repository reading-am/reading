define [
  "app/views/base/collection/view"
  "app/views/oauth_apps/oauth_app/view"
  "text!app/views/oauth_apps/oauth_apps/template.mustache"
], (CollectionView, OauthAppView, template) ->

  class OauthAppsView extends CollectionView
    @assets
      template: template

    modelView: OauthAppView
    empty_msg: "You don't have any apps yet"
