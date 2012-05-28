define [
  "jquery"
  "backbone"
  "handlebars"
  "app/models/post"
  "app/views/users/user"
  "app/views/components/share_popover"
  "plugins/humane"
  "plugins/highlight"
  "css!comments/comment"
], ($, Backbone, Handlebars, Post, UserView, SharePopover) ->

  class CommentView extends Backbone.View
    template: Handlebars.compile "
      <div class=\"r_comment_header\">
        <div class=\"r_user\"></div>
        <time datetime=\"{{updated_at}}\"></time>
        <div class=\"r_comment_actions\">
          {{#if is_owner}}<a href=\"#\" class=\"r_destroy\">Delete</a>{{/if}}
          <a href=\"#\" class=\"r_share\">Share</a>
          {{! <a href=\"#\" class=\"r_reply\">Reply</a> }}
          <a href=\"{{url}}\" class=\"r_permalink\">⚓</a>
        </div>
      </div>
      <div class=\"r_comment_body\">
        {{format_comment body}}
      </div>
    "

    tagName: "li"
    className: "r_comment"

    events:
      "click .r_permalink": "new_window"
      "click .r_share"    : "share"
      "click .r_reply"    : "reply"
      "click .r_quoted"   : "find_quote"
      "click .r_destroy"  : "destroy"
      "click a.r_url img" : "find_image"
      "click a.r_url:not(.r_mention)": "new_window"

    initialize: (options) ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this

      @size = options.size ? "small"

    share: ->
      @share_view = new SharePopover subject: @model
      @share_view.render()

    reply: ->
      alert "reply will go here"
      false

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
      console.log "hit", e.currentTarget.src
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
      @$el.html(@template(json))

      @$("time").humaneDates()

      child_view = new UserView
        el:     @$(".r_user")
        size:   @size
        model:  @model.get('user')
      child_view.render()

      return this
