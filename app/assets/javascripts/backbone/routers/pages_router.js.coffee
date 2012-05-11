class ø.Routers.Pages extends ø.Backbone.Router
  initialize: (options) ->
    if options.model
      @model = new ø.Models.Page options.model
    else
      @pages = new ø.Collections.Pages()
      @pages.reset options.pages

  routes:
    "new"      : "newPage"
    "index"    : "index"
    ":id/edit" : "edit"
    "/domains/:id/pages/:id"      : "show"
    ".*"       : "index"

  newPage: ->
    @view = new ø.Views.Pages.New(collection: @pages)
    $("#pages").html(@view.render().el)

  index: ->
    @view = new ø.Views.Pages.Index(pages: @pages)
    $("#pages").html(@view.render().el)

  show: (id) ->
    page = @pages.get(id)

    @view = new ø.Views.Pages.Show(model: page)
    $("#pages").html(@view.render().el)

  edit: (id) ->
    page = @pages.get(id)

    @view = new ø.Views.Pages.Edit(model: page)
    $("#pages").html(@view.render().el)
