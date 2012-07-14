define [
  "jquery"
  "backbone"
  "handlebars"
  "app/models/post"
  "app/views/comments/comments"
  "app/views/users/users"
  "app/views/components/share_popover"
], ($, Backbone, Handlebars, Post, CommentsView, UsersView, SharePopover) ->

  active = "r_active"
  inactive = "r_inactive"

  class BookmarkletAppView extends Backbone.View
    template: Handlebars.compile "
      <div id=\"r_wrp\">
        <div id=\"r_icon\">&#9996;</div>
        <div id=\"r_subtext\">Loading</div>
        <div id=\"r_actions\">
          <a href=\"#\" id=\"r_yep\">Yep</a> .
          <a href=\"#\" id=\"r_nope\">Nope</a>
          <a href=\"#\" id=\"r_share\">Share</a>
          <a href=\"#\" id=\"r_close\">&#10005;</a>
        </div>
      </div>"

    tagName: "div"

    id: "r_am"

    events:
      "click #r_yep, #r_nope" : "set_yn"
      "click #r_share" : "showShare"
      "click #r_close" : "close"

    initialize: ->
      @model.bind "change:yn", @render_yn, this
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

    get_comments: ->
      if @model.get("user").get("can_comment") # TODO remove once comments are public
        @comments_view = new CommentsView
          id: "r_comments"
          collection: @model.get("page").comments

        @$el.append(@comments_view.render().el)
        @comments_view.collection.fetch success: =>
          @comments_view.$el.css opacity:1 # fade in CSS transition

        @comments_view.attach_autocomplete()
        @comments_view.make_images_draggable()

    get_readers: ->
      @readers_view = new UsersView
        id: "r_readers"
        collection: @model.get("page").users

      @readers_view.collection.fetch success: (collection) =>
        collection.remove Post::current.get("user")
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
