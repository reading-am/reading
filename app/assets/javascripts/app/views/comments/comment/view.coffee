define [
  "underscore"
  "jquery"
  "backbone"
  "app/init"
  "app/models/user"
  "app/models/post"
  "app/models/uris/uri"
  "app/views/uris/uri/view"
  "app/views/users/user/view"
  "app/views/users/popover/view"
  "app/views/components/share_popover/view"
  "text!app/views/comments/comment/template.mustache"
  "text!app/views/comments/comment/styles.css"
  "app/models/uris/all"
  "app/views/uris/all"
  "extend/jquery/humane"
  "extend/jquery/highlight"
], (_, $, Backbone, App, User, Post, URI, URIView, UserView, UserPopoverView, SharePopover, template, styles) ->

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
      matches = html.match(/"(?:[^\\"]+|\\.)*"/gi)

      if matches
        cname = "r_quoted"
        config = className: cname
        $body = $("body > *:not(#r_am)")

        matches = _.map matches, (text) -> text.substring(1, text.length-1)
        matches = _.filter matches, (text) ->
          $body.highlight text, config
          if $body.find(".#{cname}").length
            $body.unhighlight config
          else
            false

        if matches
          $html = $("<div>#{html}</div>")
          config.element = "a"
          $html.highlight matches, config
          $html.find(".#{cname}").attr(href: "#")
          html = $html.html()

      return html

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

      author_view = new UserView
        el:     @$(".r_author")
        size:   @size
        model:  @model.get('user')
      author_view.render()

      return this