define [
  "app/views/base/collection"
  "app/views/pages/page_row/view"
  "app/collections/pages"
  "text!app/views/pages/pages/template.mustache"
], (CollectionView, PageRowView, Pages, template) ->

  class PagesView extends CollectionView
    modelView: PageRowView
    @assets
      template: template
