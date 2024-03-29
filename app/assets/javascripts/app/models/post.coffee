define [
  "jquery"
  "backbone"
  "app/init"
  "app/constants"
  "libs/base58"
  "extend/jquery/win_focus"
], ($, Backbone, App, Constants, Base58) ->

  class Post extends Backbone.Model
    type: "Post"

    initialize: (options) ->
      @bind "destroy", => @intervals "clear"

    validate: (attr) ->
      if !attr.page && !attr.page_id && (!attr.url || attr.url is "about:blank")
        return Constants.errors.general

    short_url: ->
      "#{Constants.short_domain}/p/#{Base58.encode(@id)}"

    # update the date_created every 15 seconds ala chartbeat
    # consider not doing this for context-menu posts
    keep_fresh: ->
      loading = false
      @intervals "add", 3, =>
        now = new Date
        if $(window).hasFocus() and not loading and now - @get("updated_at") >= 15000
          loading = true
          @save "updated_at", now, success: -> loading = false

  App.Models.Post = Post
  return Post
