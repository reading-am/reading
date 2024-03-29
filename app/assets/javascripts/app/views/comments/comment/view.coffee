define [
  "underscore"
  "jquery"
  "backbone"
  "app/init"
  "app/models/user_with_current"
  "app/models/post"
  "app/models/uris/uri"
  "app/views/uris/uri/view"
  "app/views/users/user/small/view"
  "app/views/users/overlay/view"
  "app/views/components/share_overlay/view"
  "text!app/views/comments/comment/template.mustache"
  "text!app/views/comments/comment/styles.css"
  "app/models/uris/all"
  "app/views/uris/all"
  "extend/jquery/humane"
  "extend/jquery/highlight"
], (_, $, Backbone, App, User, Post, URI, URIView, UserSmallView, UserOverlayView, ShareOverlay, template, styles) ->

  class CommentView extends Backbone.View
    @assets
      styles: styles
      template: template

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

      @uri_views = []

    show_user: (e) ->
      overlay = new UserOverlayView
        model: new User(url: $(e.target).attr("href"))
      overlay.render()
      false

    share: ->
      @share_view = new ShareOverlay subject: @model
      @share_view.render()
      false

    find_quote: (e) ->
      cname = "r_quote"
      text = $(e.currentTarget).text()
      $body = $("body > *:not(#r_am)")

      $body.unhighlight className: cname
      $body.highlight text, className: cname

      offset = $(".#{cname}").offset().top - $(window).height() / 2
      offset = 0 if offset < 0
      $(if $.browser.webkit then "body" else "html").animate scrollTop : offset

      false

    find_image: (e) ->
      $img = $("body > *:not(#r_am)").find("img[src='#{e.currentTarget.src}']")
      if $img.length
        offset = $img.offset().top + $img.height()/2 - $(window).height() / 2
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

    link_quotes: (html) ->
      $html = $("<div>#{html}</div>")
      $quotes = $html.find("i")

      if $quotes.length
        cname = "r_quoted"
        config = className: cname
        $body = $("body > *:not(#r_am)")

        $quotes.each ->
          $this = $(this)
          text = $this.html()[1..-2]
          $body.highlight text, config
          if $body.find(".#{cname}").length
            $body.unhighlight config
            $link = $("<a>").attr(class: "r_quoted", href: "#").html(text)
            $this.html("\"").append($link).append("\"")

      return $html.html()

    render: =>
      json = @model.toJSON()
      json.is_owner = (@model.get("user").get("id") == User::current.get("id"))
      json.body_html = @model.body_html()
      json.is_a_show = @model.is_a_show()

      if @model.is_a_show()
        if (m = @model.mentions().length) > 1
          json.body_html = "#{m} people"
      else
        json.body_html = @link_quotes json.body_html

      @$el.html(@template(json))

      @$("a.r_url:not(.r_mention, .r_tag, .r_email, .r_image, .r_quoted)").each (i, el) =>
        model = URI::factory el.href
        if model?
          model.fetch()
          view = URIView::factory model
          $(el).replaceWith view.render().el
          @uri_views.push view

      @$("time").humaneDates()

      author_view = new UserSmallView
        el:     @$(".r_author")
        model:  @model.get('user')
      author_view.render()

      return this
