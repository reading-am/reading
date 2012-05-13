ø.Views.Comments ||= {}

class ø.Views.Comments.CommentsView extends ø.Backbone.View
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
    view = new ø.Views.Comments.CommentView({model : comment})
    @$("ul").prepend(view.render().el)

  showUser: (e) ->
    popover = new ø.Views.Users.UserPopoverView
      model: new ø.Models.User(url: ø.$(e.target).attr("href"))
    popover.render()
    false

  createOnEnter: (e) ->
      if e.keyCode is 13 and !key.alt
        @collection.create
          body: @$("textarea").val(),
          post: ø.Models.Post::current
          user: ø.Models.Post::current.get("user")
          page: ø.Models.Post::current.get("page")
        @$("textarea")
          .val("")
          .mentionsInput("reset")
        @$("ul").animate
          scrollTop: 0
          duration: "fast"
        false

  attach_autocomplete: ø._.once ->
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

          callback.call this, ø._.map data, (user) ->
            user = user.toJSON()
            user.username = "@#{user.username}"
            user

        if following
          finish following
        else
          following = ø.Models.Post::current.get("user").following
          following.fetch success: finish

  render: =>
    ø.$(@el).html(@template())
    @addAll()
    return this
