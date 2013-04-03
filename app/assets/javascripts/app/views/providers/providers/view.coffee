define [
  "app/views/base/collection"
  "app/views/providers/provider/view"
  "text!app/views/providers/provider/template.mustache"
], (CollectionView, ProviderView, template) ->

  class ProvidersView extends CollectionView
    @parse_template template
    modelView: ProviderView
