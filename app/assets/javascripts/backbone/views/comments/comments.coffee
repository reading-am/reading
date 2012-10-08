define [
  "backbone"
  "app/views/comments/comment"
], (Backbone, CommentView) ->

  class CommentsView extends Backbone.View
    tagName: "ul"
    className: "r_comments_list"

    initialize: ->
      @collection.bind "reset", @addAll
      @collection.bind "add", @addOne

    addAll: =>
      @collection.each @addOne

    addOne: (comment) =>
      view = new CommentView model:comment

      i = @collection.length-1 - @collection.indexOf(comment)
      li_len = @$("li").length

      # add comments in order if we're only adding one of them
      if li_len is @collection.length-1 and i
        @$("li:eq(#{i-1})").after(view.render().el)
      else
        @$el.prepend(view.render().el)

    render: =>
      @addAll()
      return this
