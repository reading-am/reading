define [
  "jquery"
  "backbone"
  "handlebars"
  "app/init"
  "app/models/user"
  "app/models/post"
  "app/models/uris/uri"
  "app/views/uris/uri"
  "app/views/users/user"
  "app/views/users/popover"
  "app/views/components/share_popover"
  "text!app/templates/comments/comment.hbs"
  "text!app/templates/comments/comment_shown.hbs"
  "text!comments/comment.css"
  "app/models/uris/all"
  "app/views/uris/all"
  "extend/jquery/humane"
  "extend/jquery/highlight"
], ($, Backbone, Handlebars, App, User, Post, URI, URIView, UserView, UserPopoverView, SharePopover, template, shown_template, css) ->

  $("<style>").html(css).appendTo("head")

  class CommentView extends Backbone.View
    template: Handlebars.compile template
    shown_template: Handlebars.compile shown_template

    tagName: "li"
    className: "r_comment"

    events:
      "click .r_permalink": "new_window"
      "click .r_mention"  : "show_user"
      "click .r_share"    : "share"
      "click .r_quoted"   : "find_quote"
      "click .r_destroy"  : "destroy"
      "click a.r_url img" : "find_image"
      "click a.r_url:not(.r_mention)": "new_window"

    initialize: (options) ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this
      @model.bind "remove", @remove, this

      @size = options.size ? "small"
      @uri_views = []

    show_user: (e) ->
      popover = new UserPopoverView
        model: new User(url: $(e.target).attr("href"))
      popover.render()
      false

    share: ->
      @share_view = new SharePopover subject: @model
      @share_view.render()

    find_quote: (e) ->
      cname = "r_quote"
      text = $(e.currentTarget).text()
      $body = $("body > *:not(#r_am)")

      $body.unhighlight className: cname
      $body.highlight text, className: cname

      offset = $(".#{cname}").offset().top - $(window).height()/2
      offset = 0 if offset < 0
      $(if $.browser.webkit then "body" else "html").animate scrollTop : offset

      false

    find_image: (e) ->
      $img = $("body > *:not(#r_am)").find("img[src='#{e.currentTarget.src}']")
      if $img.length
        offset = $img.offset().top + $img.height()/2 - $(window).height()/2
        offset = 0 if offset < 0
        $(if $.browser.webkit then "body" else "html").animate scrollTop : offset
        false

    new_window: (e) ->
      window.open e.currentTarget.href
      false

    destroy: ->
      if confirm "Are you sure you want to delete this comment?"
        @model.destroy()

      false

    render: =>
      json = @model.toJSON()
      # TODO there has to be a better current_user solution here
      # this is being shared between the main site and the bookmarklet
      json.is_owner = (Post::current? and @model.get("user").get("id") == Post::current.get("user").get("id"))

      if @model.is_a_show()
        @$el.html(@shown_template(json))
      else
        @$el.html(@template(json))

      @$("a.r_url:not(.r_mention, .r_tag, .r_email, .r_image, .r_quoted)").each (i, el) =>
        model = URI::factory el.href
        if model?
          model.fetch()
          view = URIView::factory model
          $(el).replaceWith view.render().el
          @uri_views.push view

      @$("time").humaneDates()

      author_view = new UserView
        el:     @$(".r_author")
        size:   @size
        model:  @model.get('user')
      author_view.render()

      return this
