define [
  "app/views/base/collection"
  "app/views/pages/page_row/view"
  "text!app/views/pages/pages/template.mustache"
], (CollectionView, PageRowView, template) ->

  class PagesView extends CollectionView
    modelView: PageRowView
    @parse_template template
