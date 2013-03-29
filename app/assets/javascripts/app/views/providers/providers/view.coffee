define [
  "app/views/base/collection"
  "app/views/providers/provider/view"
], (CollectionView, ProviderView) ->

  class ProvidersView extends CollectionView
    modelView: ProviderView
