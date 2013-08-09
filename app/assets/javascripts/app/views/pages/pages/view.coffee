define [
  "app/views/base/collection/view"
  "app/views/pages/page_row/view"
  "text!app/views/pages/pages/template.mustache"
  "text!app/views/pages/pages/styles.css"
], (CollectionView, PageRowView, template, styles) ->

  class PagesView extends CollectionView
    @assets
      template: template
      styles: styles

    modelView: PageRowView
