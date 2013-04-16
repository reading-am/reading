define [
  "jquery"
  "underscore"
  "backbone"
  "pusher"
  "app/models/post"
  "app/models/user"
  "app/views/comments/comments_with_input/view"
  "app/views/posts/posts_grouped_by_user/view"
  "app/views/components/share_popover/view"
  "text!app/views/bookmarklet/app/template.mustache"
], ($, _, Backbone, pusher, Post, User, CommentsWithInputView, PostsView, SharePopover, template) ->

  active = "r_active"
  inactive = "r_inactive"

  class BookmarkletAppView extends Backbone.View
    @assets
      template: template

    events:
      "click #r_yep, #r_nope" : "set_yn"
      "click #r_share" : "showShare"
      "click #r_close" : "close"

    initialize: ->
      @model.bind "change:yn", @render_yn, this
      @model.bind "change:id", @sub_presence, this
      @model.bind "change:id", @get_comments, this
      @model.bind "change:id", @get_readers, this

      @prep_page()
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

        $body = $("<body>").attr(id: "r_body").hide().append $iframe
        $("html").append $body

      else
        @insert()

    insert: ->
      @$el.appendTo("body").fadeIn 500

      @$("#r_wrp").delay(500).animate
        height: "29px"
        width: @$("#r_actions").width()-4

      @$("#r_icon").delay(500).animate "margin-top": "-56px"

    sub_presence: ->
      @presence = pusher.subscribe "presence-pages.#{@model.get("page").id}"

    get_comments: ->
      @comments_view = new CommentsWithInputView
        collection: @model.get("page").comments
        post: Post::current
        user: User::current
        page: Post::current.get("page")

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
        $other = @$("#r_other")
        $other.after(@readers_view.el)
        # only display if there are other readers
        $other.add(@readers_view.el).slideDown() if collection.length > 1

        collection.monitor()

        @monitor_presence()
        @monitor_focus()
        @monitor_typing()

    monitor_presence: ->
      @presence.members.each (member) =>
        @readers_view.is_online Number(member.id), true

      @presence.bind "pusher:member_removed", (member) =>
        @readers_view.is_online Number(member.id), false

      @presence.bind "pusher:member_added", (member) =>
        @readers_view.is_online Number(member.id), true
        # display if another reader arrives
        @$("#r_other").add(@readers_view.el).slideDown() if @readers_view.collection.length is 2

    monitor_focus: ->
      $(window).focus(=>
        @presence.trigger "client-win-focus", id: User::current.get("id")
      ).blur =>
        @presence.trigger "client-win-blur", id: User::current.get("id")

      @presence.bind "client-win-focus", (member) =>
        @readers_view.is_blurred member.id, false

      @presence.bind "client-win-blur", (member) =>
        @readers_view.is_blurred member.id, true

    monitor_typing: ->
      typing_delay = 2000
      typing_timers = {}

      @comments_view.bind "typing", _.throttle =>
          @presence.trigger "client-typing", id: User::current.get("id")
        , typing_delay

      @comments_view.collection.bind "add", (comment) =>
        @readers_view.is_typing comment.get("user").id, false
        clearTimeout typing_timers[comment.get("user").id]

      @presence.bind "client-typing", (member) =>
        if typing_timers[member.id]?
          clearTimeout typing_timers[member.id]
        else
          @readers_view.is_typing member.id, true

        typing_timers[member.id] = setTimeout =>
          @readers_view.is_typing member.id, false
          delete typing_timers[member.id]
        , typing_delay

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

    prep_page: ->
      # Disable annoying clipboard hijackers
      delete window.Tynt

    render: =>
      @$el.html(@template(@model.toJSON()))
      return this
