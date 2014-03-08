define [
  "app/views/base/collection/view"
  "app/views/providers/provider/view"
  "text!app/views/providers/provider/template.mustache"
], (CollectionView, ProviderView, template) ->

  class ProvidersView extends CollectionView
    @assets
      template: template
    modelView: ProviderView
