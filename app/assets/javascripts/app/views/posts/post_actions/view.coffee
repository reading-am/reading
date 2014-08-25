define [
  "jquery"
  "app/views/base/model"
  "app/models/post"
  "app/views/components/share_overlay/view"
  "text!app/views/posts/post_actions/template.mustache"
  "text!app/views/posts/post_actions/styles.css"
], ($, ModelView, Post, ShareOverlay, template, styles) ->

  class PostActionsView extends ModelView
    @assets
      template: template
      styles: styles

    events:
      "click .pa_create": "create"
      "click .pa_destroy": "destroy"
      "click .pa_yep" : "yep"
      "click .pa_nope" : "nope"
      "click .pa_share" : "share"

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
      @set_model() # there could be more than one
      @render()

    create: ->
      post = new Post
        user: @user
        page: @page
        referrer_post: @collection.first()

      if post.isValid()
        @collection.create post, wait: true
        @set_model()
      false

    destroy: ->
      if confirm "Are you sure you want to delete this post?"
        @model.destroy()
      false

    yep: ->
      @model.save yn: (if @model.get("yn") is true then null else true)
      false

    nope: ->
      @model.save yn: (if @model.get("yn") is false then null else false)
      false

    share: ->
      @share_view = new ShareOverlay subject: @model || @collection.first()
      @share_view.render()
      false

    json: ->
      if @model
        data = @model.toJSON()
        data.yep = @model.get("yn") is true
        data.nope = @model.get("yn") is false
      data
