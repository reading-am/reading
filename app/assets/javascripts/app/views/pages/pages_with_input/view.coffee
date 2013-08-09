define [
  "jquery"
  "underscore"
  "backbone"
  "app/models/post"
  "app/views/pages/pages/view"
  "app/views/posts/posts_grouped_by_page/view"
  "text!app/views/pages/pages_with_input/template.mustache"
], ($, _, Backbone, Post, PagesView, PostsGroupedByPageView, template) ->

  class PagesWithInputView extends Backbone.View
    @assets
      template: template

    events:
      "submit form": "submit"

    initialize: (options) ->
      props =
        collection: @collection
        el: options.subview_el

      if @collection.type is "Posts"
        @subview = new PostsGroupedByPageView props
      else
        @subview = new PagesView props

    toggle_loading: ->
      msg = "Posting..."
      @input.val if @input.val() is msg then "" else msg
      @row.toggleClass "disabled"
      @$("input").attr disabled: @row.hasClass "disabled"
      # The line above used to read like this:
      # @$("input").each -> @disabled = !@disabled
      # It worked fine for adding disabled but would only remove
      # disabled for one of the two elements. Why? WHY!?

    submit: ->
      val = @input.val()
      @toggle_loading()

      post = new Post
      post.save {url: val}, success: =>
        @subview.collection.add post
        @subview.$el.find('div:first').hide().slideDown()
        @row.slideUp complete: => @toggle_loading()

      false

    render: ->
      @$el.html(@template())
          .append(@subview.render().el)

      @input = @$("form input[type=text]")
      @row = @$("#new_post_row")
      @use_extension = @$("#new_post_use_extension")
      @loading = @$("new_post_loading")

      return this

