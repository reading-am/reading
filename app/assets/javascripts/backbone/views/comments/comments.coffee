ø.Views.Comments ||= {}

class ø.Views.Comments.CommentsView extends ø.Backbone.View
  template: Handlebars.compile "
    <textarea placeholder=\"Add a comment\"></textarea>
    <ul></ul>
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
        @$("textarea").val ""
        @$("ul").animate
          scrollTop: 0
          duration: "fast"
        false

    render: =>
      ø.$(@el).html(@template())
      @addAll()
      return this
