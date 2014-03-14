define [
  "underscore"
  "jquery"
  "backbone"
  "libs/keymaster"
  "app/views/comments/comments/view"
  "app/models/comment"
  "app/models/post"
  "app/models/user_with_current"
  "app/collections/users"
  "text!app/views/comments/comments_with_input/template.mustache"
  "text!app/views/comments/comments_with_input/styles.css"
  "jquery_ui"
  "extend/jquery/mentionsInput"
  "extend/jquery/events.input"
  "extend/jquery/elastic"
  "extend/jquery/insert_at_caret"
], (_, $, Backbone, Key, CommentsView, Comment, Post, User, Users, template, styles) ->

  class CommentsWithInputView extends Backbone.View
    @assets
      styles: styles
      template: template

    events:
      "keydown textarea"  : "stop_propagation"
      "keypress textarea" : "delegate_keys"

    initialize: (options) ->
      @subview = new CommentsView collection: @collection
      @user = options.user
      @post = options.post
      @page = options.page

    stop_propagation:(e) ->
      # this prevents the page's existing events
      # from intercepting the keydown and returning false,
      # thereby preventing a character from being entered
      # and preventing keydown from being fired.
      # ex: The spacebar on Google Image Search
      e.stopPropagation()
      # But we still want our lib/keymaster to track the events
      Key.dispatch e

    delegate_keys:(e) ->
      # prevent preexisting handlers from firing
      e.stopPropagation()

      if e.keyCode is 13 and !Key.alt
        @submit()
      else
        @typing()

    # this is throttled because it was causing latency while typing
    typing: _.throttle ->
        @trigger "typing"
      , 500

    submit: ->
      comment = new Comment
        body: @textarea.val(),
        post: @post
        user: @user
        page: @page

      if comment.isValid()
        @subview.collection.create comment

        @textarea
          .val("")
          .mentionsInput("reset")

      @$("ul").animate
        scrollTop: 0
        duration: "fast"

      false

    make_images_draggable: _.once ->
      $("img").draggable
        helper:'clone'
        addClass: false
        opacity: 0.5
        zIndex: 2147483647

      @textarea.droppable
        accept: "img"
        tolerance: "pointer"
        addClasses: false
        activeClass: "r_drag_active"
        hoverClass: "r_drag_hover"
        drop: (event, ui) =>
          # .src gives us the absolute path rather than the relative path from .attr('src')
          @textarea.insertAtCaret ui.draggable[0].src

    attach_autocomplete: ->
      # cache the users after fetching
      ac_col = false
      # cache the last callback so that, when user.following
      # finally fetches, it's filtered against the current query string
      last_cb = ->

      # this should only be called after it's been attached to the DOM
      @textarea.mentionsInput
        schema:
          name:     "username"
          alt_name: "full_name"
          avatar:   "avatar_mini"

        classes:
          autoCompleteItemActive : "r_active"

        onDataRequest: (mode, query, callback) =>
          finish = (collection) =>
            data = collection.filter (user) ->
              "#{user.get("username")} #{user.get("display_name")}".toLowerCase().indexOf(query.toLowerCase()) > -1

            callback.call this, _.map data, (user) ->
              user = user.toJSON()
              user.username = "@#{user.username}"
              user

          if !ac_col
            # Seed it with users listed in "Other Readers"
            ac_col = new Users(@page.posts.models.map (post) -> post.get("user"))
            count = @user.get("following_count")
            if count > 0
              @user.following.params.limit = 200
              @user.following.fetchNRecords count, success: (col) ->
                ac_col.add col.models
                last_cb ac_col

          last_cb = finish
          finish ac_col

    render: =>
      @$el.html(@template({signed_in: User::current.signed_in()}))
          .append(@subview.render().el)

      @textarea = @$("textarea")

      return this
