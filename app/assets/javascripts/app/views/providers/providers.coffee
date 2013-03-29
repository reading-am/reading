define [
  "app/views/base/collection"
  "app/views/providers/provider"
], (CollectionView, ProviderView) ->

  class ProvidersView extends CollectionView
    modelView: ProviderView
