reading.define [
  "jquery"
  "backbone"
  "handlebars"
  "app"
  "app/models/post"
  "app/models/uris/uri"
  "app/views/uris/uri"
  "app/views/users/user"
  "app/views/components/share_popover"
  "app/models/uris/all"
  "app/views/uris/all"
  "plugins/humane"
  "plugins/highlight"
  "css!comments/comment"
], ($, Backbone, Handlebars, App, Post, URI, URIView, UserView, SharePopover) ->

  class CommentView extends Backbone.View
    template: Handlebars.compile "
      <div class=\"r_comment_header\">
        <div class=\"r_author r_user\"></div>
        <time datetime=\"{{updated_at}}\"></time>
        <div class=\"r_comment_actions\">
          {{#if is_owner}}<a href=\"#\" class=\"r_destroy\">Delete</a>{{/if}}
          <a href=\"#\" class=\"r_share\">Share</a>
          <a href=\"{{url}}\" class=\"r_permalink\">⚓</a>
        </div>
      </div>
      <div class=\"r_comment_body\">
        {{format_comment body}}
      </div>
    "

    shown_template: Handlebars.compile "
      <div class=\"r_comment_header\">
        <div class=\"r_author r_user\"></div>
        <div class=\"r_showed_this_to\">showed this to</div>
        <div class=\"r_shown_user r_user\">{{format_comment body}}</div>
      </div>
    "

    tagName: "li"
    className: "r_comment"

    events:
      "click .r_permalink": "new_window"
      "click .r_share"    : "share"
      "click .r_quoted"   : "find_quote"
      "click .r_destroy"  : "destroy"
      "click a.r_url img" : "find_image"
      "click a.r_url:not(.r_mention)": "new_window"

    initialize: (options) ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this

      @size = options.size ? "small"
      @uri_views = []

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
