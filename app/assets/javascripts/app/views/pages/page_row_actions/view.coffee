define [
  "backbone"
  "app/models/post"
  "text!app/views/pages/page_row_actions/template.mustache"
], (Backbone, Post, template) ->

  class PageRowActionsView extends Backbone.View
    @assets
      template: template

    events:
      "click .pa_create": "create"
      "click .pa_destroy": "destroy"

    initialize: (options) ->
      @user = options.user
      @page = options.page
      @bind() if @model

    bind: =>
      @model.on "change", @render, this
      @model.on "destroy", @remove, this
      @model.on "remove", @remove, this

    remove: ->
      @$(".pa_create").show()
      @$(".pa_destroy").hide()

    create: ->
      @model = new Post
        user: @user
        page: @page

      if @model.isValid()
        @collection.create @model
        @bind()

      false

    destroy: ->
      if confirm "Are you sure you want to delete this post?"
        @model.destroy()

      false

    render: ->
      @$el.html(@template(@model?.toJSON()))
      return this
