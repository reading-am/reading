define [
  "jquery"
  "backbone"
  "handlebars"
  "pusher"
  "app/models/post"
  "app/views/comments/comments"
  "app/views/posts/posts_grouped_by_user"
  "app/views/components/share_popover"
  "text!app/templates/bookmarklet/app.hbs"
], ($, Backbone, Handlebars, pusher, Post, CommentsView, PostsView, SharePopover, template) ->

  active = "r_active"
  inactive = "r_inactive"

  class BookmarkletAppView extends Backbone.View
    template: Handlebars.compile template

    tagName: "div"

    id: "r_am"

    events:
      "click #r_yep, #r_nope" : "set_yn"
      "click #r_share" : "showShare"
      "click #r_close" : "close"

    initialize: ->
      @model.bind "change:yn", @render_yn, this
      @model.bind "change:id", @sub_presence, this
      @model.bind "change:id", @get_comments, this
      @model.bind "change:id", @get_readers, this

      @render()

      @intervals "add", 15, => @$("time").humaneDates()

      # prevent # from showing up in the url
      # can't bind in events because of conflicts
      @$el.on "click", "a[href=#]", -> false

      # if the page has a frameset, create a body and reload the page in an iframe
      $frameset = $("frameset")
      if $frameset.length
        $iframe = $("<iframe>").attr(
          id: "r_iframe"
          src: window.location.href
        ).load =>
          $frameset.remove()
          $body.show()
          @insert()
          # reinitialize elastic because it fails if the item wasn't on the DOM
          # when it was first called TODO - roll this into the comment view
          @comments_view.textarea.elastic() if @comments_view?

        $body = $("<body>").attr(id: "r_body").hide().append $iframe
        $("html").append $body

      else
        @insert()

    insert: ->
      @$el.prependTo("body").fadeIn 500

      @$("#r_wrp").delay(500).animate
        height: "29px"
        width: @$("#r_actions").width()

      @$("#r_icon").delay(500).animate "margin-top": "-56px"

    sub_presence: ->
      @presence = pusher.subscribe "presence-pages.#{@model.get("page").id}"

    get_comments: ->
      if @model.get("user").get("can_comment") # TODO remove once comments are public
        @comments_view = new CommentsView
          id: "r_comments"
          collection: @model.get("page").comments

        @$el.append(@comments_view.render().el)
        @comments_view.collection.fetch success: =>
          @comments_view.collection.monitor()
          @comments_view.$el.css opacity:1 # fade in CSS transition

        @comments_view.attach_autocomplete()
        @comments_view.make_images_draggable()

    get_readers: ->
      @readers_view = new PostsView
        id: "r_readers"
        collection: @model.get("page").posts

      @readers_view.collection.fetch success: (collection) =>
        @readers_view.collection.monitor()
        # remove the current user from the other readers list
        collection.remove(collection.filter((post) -> post.get("user").id is Post::current.get("user").id))

        if collection.length > 0
          @$("#r_wrp").after(@readers_view.$el.prepend("<li id=\"r_other\">&#8258; Other Readers</li>"))
          @readers_view.$el.slideDown()

    set_yn: (e) ->
      $tar = $(e.target)
      @model.save
        yn: (if @$el.hasClass($tar.attr("id")) then null else $tar.is("#r_yep"))

    render_yn: ->
      $this  = (if @model.get("yn") then @$("#r_yep") else @$("#r_nope"))

      # set the UI
      @$el.removeClass("r_yep r_nope")
      if @model.get("yn") isnt null
        @$el.addClass(if @model.get("yn") then "r_yep" else "r_nope")

    showShare: ->
      @share_view = new SharePopover subject: Post::current
      @share_view.render()

    close: ->
      @intervals "clear"
      @model.intervals "clear"
      @$el.fadeOut 400, =>
        @$el.remove()
      false

    render: =>
      @$el.html(@template(@model.toJSON()))
      return this
