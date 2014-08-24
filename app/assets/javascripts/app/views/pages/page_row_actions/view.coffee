define [
  "app/models/post"
  "app/models/user_with_current"
  "app/views/base/model"
  "text!app/views/pages/page_row_actions/template.mustache"
], (Post, User, ModelView, template) ->

  class PageRowActionsView extends ModelView
    @assets
      template: template

    events:
      "click .pa_create": "create"
      "click .pa_destroy": "destroy"

    initialize: (options) ->
      @model ?= new Post user: User::current, page: options.page
      @model.on "change", @render, this
      @model.on "remove", @remove, this

    remove: ->
      @$(".pa_create").show()
      @$(".pa_destroy").hide()

    create: ->
      @model.save()

    destroy: ->
      if confirm "Are you sure you want to delete this post?"
        @model.destroy()

      false
