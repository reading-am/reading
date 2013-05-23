define [
  "jquery"
  "underscore"
  "backbone"
  "app/models/user_with_current"
  "app/models/post"
  "app/views/pages/pages/view"
  "app/views/posts/posts_grouped_by_page/view"
  "text!app/views/pages/pages_with_input/template.mustache"
  "text!app/views/pages/pages_with_input/styles.css"
], ($, _, Backbone, User, Post, PagesView, PostsGroupedByPageView, template, styles) ->

  class PagesWithInputView extends Backbone.View
    @assets
      template: template
      styles: styles

    events:
      "submit form": "submit"

    initialize: ->
      if @collection.type is "Posts"
        @subview = new PostsGroupedByPageView collection: @collection
      else
        @subview = new PagesView collection: @collection

    toggle_loading: ->
      msg = "Posting..."
      @input.val if @input.val() is msg then "" else msg
      @header.toggleClass "disabled"
      @$("input").attr disabled: @header.hasClass "disabled"
      # The line above used to read like this:
      # @$("input").each -> @disabled = !@disabled
      # It worked fine for adding disabled but would only remove
      # disabled for one of the two elements. Why? WHY!?


    submit: ->
      val = @input.val()
      @toggle_loading()

      post = new Post
      post.save {url: val}, success: =>
        page = post.get("page")
        page.posts.add post

        @subview.collection.add page
        @subview.$el.find('div:first').hide().slideDown()
        @toggle_loading()

      false

    json: ->
      has_avatar = true
      {
        avatar_link_url:    if has_avatar then User::current.get("avatar") else "/settings/info",
        avatar_link_target: if has_avatar then "_blank" else false,
        avatar_medium:      User::current.get("avatar_medium")
      }

    render: =>
      @$el.html(@template(@json()))
          .append(@subview.render().el)

      @input = @$("form input[type=text]")
      @header = @$(".r_header")

      return this

