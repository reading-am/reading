define [
  "jquery"
  "underscore"
  "backbone"
  "handlebars"
  "libs/keymaster"
  "app/views/comments/comments"
  "app/models/post"
  "text!app/templates/comments/comments_with_input.hbs"
  "jquery_ui"
  "extend/jquery/mentionsInput"
  "extend/jquery/events.input"
  "extend/jquery/elastic"
  "extend/jquery/insert_at_caret"
], ($, _, Backbone, Handlebars, Key, CommentsView, Post, template) ->

  class CommentsWithInputView extends Backbone.View
    template: Handlebars.compile template

    tagName: "div"

    events:
      "keydown textarea"  : "stop_propagation"
      "keypress textarea" : "delegate_keys"

    initialize: ->
      @subview = new CommentsView collection: @collection

    stop_propagation:(e) ->
      # this prevents the page's existing events
      # from intercepting the keydown and returning false,
      # thereby preventing a character from being entered
      # and preventing keydown from being fired.
      # ex: The spacebar on Google Image Search
      e.stopPropagation()

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
      @subview.collection.create
        body: @textarea.val(),
        post: Post::current
        user: Post::current.get("user")
        page: Post::current.get("page")

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
      following = false

      # this should only be called after it's been attached to the DOM
      @textarea.mentionsInput
        schema:
          name:     "username"
          alt_name: "full_name"
          avatar:   "avatar_mini"

        classes:
          autoCompleteItemActive : "r_active"

        onDataRequest: (mode, query, callback) ->
          finish = (collection) =>
            data = collection.filter (user) ->
              "#{user.get("username")} #{user.get("display_name")}".toLowerCase().indexOf(query.toLowerCase()) > -1

            callback.call this, _.map data, (user) ->
              user = user.toJSON()
              user.username = "@#{user.username}"
              user

          if following
            finish following
          else
            user = Post::current.get("user")
            following = user.following
            if user.get("following_count") > 0
              following.fetch success: finish
            else
              finish following

    render: =>
      @$el.html(@template())
          .append(@subview.render().el)

      @textarea = @$("textarea")

      return this
