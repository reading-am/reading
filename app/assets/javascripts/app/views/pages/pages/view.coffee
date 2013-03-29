define [
  "app/views/base/collection"
  "app/views/pages/page_row/view"
], (CollectionView, PageRowView) ->

  class PagesView extends CollectionView
    modelView: PageRowView

    tagName: "div"
    className: "r_pages"
