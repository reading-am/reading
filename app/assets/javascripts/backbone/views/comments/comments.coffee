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
        @$("textarea")
          .val("")
          .mentionsInput("reset")
        @$("ul").animate
          scrollTop: 0
          duration: "fast"
        false

  attach_autocomplete: ø._.once ->
    # this should only be called after it's been attached to the DOM
    @$("textarea").mentionsInput
      onDataRequest: (mode, query, callback) ->
        data = [
          { id:1, name:'Kenneth Auchenberg', 'avatar':'http://cdn0.4dots.com/i/customavatars/avatar7112_1.gif', 'type':'contact' },
          { id:2, name:'Jon Froda', 'avatar':'http://cdn0.4dots.com/i/customavatars/avatar7112_1.gif', 'type':'contact' },
          { id:3, name:'Anders Pollas', 'avatar':'http://cdn0.4dots.com/i/customavatars/avatar7112_1.gif', 'type':'contact' },
          { id:4, name:'Kasper Hulthin', 'avatar':'http://cdn0.4dots.com/i/customavatars/avatar7112_1.gif', 'type':'contact' },
          { id:5, name:'Andreas Haugstrup', 'avatar':'http://cdn0.4dots.com/i/customavatars/avatar7112_1.gif', 'type':'contact' },
          { id:6, name:'Pete Lacey', 'avatar':'http://cdn0.4dots.com/i/customavatars/avatar7112_1.gif', 'type':'contact' }
        ]
        #data = ø.Models.Post::current.get("user").following()
        data = ø._.filter(data, (item) -> item.name.toLowerCase().indexOf(query.toLowerCase()) > -1 )
        callback.call this, data

  render: =>
    ø.$(@el).html(@template())
    @addAll()
    return this
