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

      @collection.on "add", @set_model, this
      @set_model()

    set_model: ->
      post = @collection.find((post) => post.get("user").id is @user.id)
      if post && post isnt @model
        @model = post
        @model.on "change", @render, this
        @model.on "destroy", @remove, this
        @model.on "remove", @remove, this
        @render()

    remove: ->
      delete @model
      @render()

    create: ->
      post = new Post
        user: @user
        page: @page

      if post.isValid()
        @collection.create post
        @set_model()

      false

    destroy: ->
      if confirm "Are you sure you want to delete this post?"
        @model.destroy()

      false

    render: ->
      @$el.html(@template(@model?.toJSON()))
      return this
