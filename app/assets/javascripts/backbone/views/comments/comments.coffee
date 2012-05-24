define [
  "jquery"
  "underscore"
  "backbone"
  "handlebars"
  "libs/keymaster"
  "app/views/comments/comment"
  "app/views/users/popover"
  "app/models/user"
  "app/models/post"
  "jquery_ui"
  "plugins/mentionsInput"
  "plugins/events.input"
  "plugins/elastic"
  "plugins/insert_at_caret"
], ($, _, Backbone, Handlebars, Key, CommentView, UserPopoverView, User, Post) ->

  class CommentsView extends Backbone.View
    template: Handlebars.compile "
      <textarea placeholder=\"Add a comment\"></textarea>
      <ul class=\"r_comments_list\"></ul>
    "

    tagName: "div"

    events:
      "keypress textarea" : "createOnEnter",
      "click .r_mention" : "showUser"

    initialize: ->
      @collection.bind "reset", @addAll
      @collection.bind "add", @addOne

    addAll: =>
      @collection.each(@addOne)

    addOne: (comment) =>
      view = new CommentView({model : comment})
      @$("ul").prepend(view.render().el)

    showUser: (e) ->
      popover = new UserPopoverView
        model: new User(url: $(e.target).attr("href"))
      popover.render()
      false

    createOnEnter: (e) ->
        if e.keyCode is 13 and !Key.alt
          @collection.create
            body: @$("textarea").val(),
            post: Post::current
            user: Post::current.get("user")
            page: Post::current.get("page")
          @$("textarea")
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
        zIndex: 9999999999
      @$("textarea").droppable
        accept: "img"
        tolerance: "pointer"
        addClasses: false
        activeClass: "r_drag_active"
        hoverClass: "r_drag_hover"
        drop: (event, ui) =>
          @$("textarea").insertAtCaret ui.draggable.attr("src")

    attach_autocomplete: ->
      following = false

      # this should only be called after it's been attached to the DOM
      @$("textarea").mentionsInput
        schema:
          name: "username"
          alt_name: "full_name"
          avatar: "mini_avatar"

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
      $(@el).html(@template())
      @addAll()
      return this
