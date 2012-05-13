active = "r_active"
inactive = "r_inactive"

class ø.Views.BookmarkletApp extends ø.Backbone.View
  template: Handlebars.compile "
    <div id=\"r_wrp\">
      <div id=\"r_icon\">&#9996;</div>
      <div id=\"r_subtext\">Loading</div>
      <div id=\"r_actions\">
        <a href=\"#\" id=\"r_yep\">Yep</a> .
        <a href=\"#\" id=\"r_nope\">Nope</a>
        <a href=\"#\" id=\"r_share\">Share</a>
        <a href=\"#\" id=\"r_close\">&#10005;</a>
      </div>
    </div>"

  tagName: "div"

  id: "r_am"

  events:
    "click #r_yep, #r_nope" : "set_yn"
    "mouseenter #r_share" : "show_share"
    "mouseleave, mouseleave #r_share" : "hide_share"
    "mouseleave" : "hide_share"
    "mouseenter #r_actions a:not(#r_share)" : "hide_share"
    "click #r_close" : "close"

  initialize: ->
    @model.bind "change:yn", @render_yn, this
    @model.bind "change:id", @get_comments, this
    @model.bind "change:id", @get_readers, this

    @render()

    @intervals "add", 15, => @$("time").humaneDates()

    @share_view = new ø.Views.Providers.ProvidersView
      id: "r_share_menu"
      collection: new ø.Collections.Providers [
        new ø.Models.Provider
          name: "Twitter"
          url_scheme: "https://twitter.com/share?url={{short_url}}&text=✌%20Reading%20%22{{title}}%22"
          action: (url) ->
            popup url, 475, 345
        new ø.Models.Provider
          name: "Facebook"
          url_scheme: "https://www.facebook.com/sharer.php?u={{wrapped_url}}&t={{title}}"
          action: (url) ->
            popup url, 520, 370
        new ø.Models.Provider
          name: "Tumblr"
          url_scheme: "http://www.tumblr.com/share?v=3&u={{wrapped_url}}&t=✌%20Reading%20%22{{title}}%22"
          action: (url) ->
            popup url, 450, 430
        new ø.Models.Provider
          name: "Instapaper"
          url_scheme: "http://www.instapaper.com/hello2?url={{url}}&title={{title}}"
          action: (url) ->
            window.location = url
        new ø.Models.Provider
          name: "Readability"
          url_scheme: "http://www.readability.com/save?url={{url}}"
          action: (url) ->
            window.location = url
        new ø.Models.Provider
          name: "Pocket"
          url_scheme: "https://getpocket.com/save?url={{url}}&title={{title}}"
          action: (url) ->
            popup url, 490, 400
        new ø.Models.Provider
          name: "Pinboard"
          url_scheme: "https://pinboard.in/add?showtags=yes&url={{url}}&title={{title}}&tags=ø.am"
          action: (url) ->
            popup url, 490, 400
        new ø.Models.Provider
          name: "Email"
          url_scheme: "mailto:?subject=✌%20Reading%20%22{{title}}%22&body={{wrapped_url}}"
          action: (url) ->
            window.location.href = url
      ]
    @$("#r_wrp").after(@share_view.render().el)

    # prevent # from showing up in the url
    # can't bind in events because of conflicts
    @$el.on "click", "a[href=#]", -> false

    @$el.prependTo("body").fadeIn 500

    @$("#r_wrp").delay(500).animate
      height: "29px"
      width: @$("#r_actions").width()

    @$("#r_icon").delay(500).animate "margin-top": "-56px"

  get_comments: ->
    @comments_view = new ø.Views.Comments.CommentsView
      id: "r_comments"
      collection: @model.get("page").comments

    @comments_view.collection.fetch()
    @$el.append(@comments_view.render().el)

    @comments_view.attach_autocomplete()

  get_readers: ->
    @readers_view = new ø.Views.Users.UsersView
      id: "r_readers"
      collection: @model.get("page").users

    @readers_view.collection.fetch()
    @$("#r_wrp").after(@readers_view.render().$el.prepend("<li id=\"r_other\">&#8258; Other Readers</li>"))
    @readers_view.$el.slideDown()

  set_yn: (e) ->
    $tar = ø.$(e.target)
    @model.save
      yn: (if $tar.hasClass(active) then null else $tar.is("#r_yep"))

  render_yn: ->
    $this  = (if @model.get("yn") then @$("#r_yep") else @$("#r_nope"))
    $other = (if @model.get("yn") then @$("#r_nope") else @$("#r_yep"))

    # set the UI
    if @model.get("yn") is null
      $this.removeClass "#{active} #{inactive}"
      $other.removeClass "#{active} #{inactive}"
    else
      $this.removeClass(inactive).addClass active
      $other.removeClass(active).addClass inactive

  show_share: ->
    @share_view.$el.show()
    @readers_view.$el.hide()
    ø.$('#r_share').addClass "r_active"
    false

  hide_share: ->
    @share_view.$el.hide()
    @readers_view.$el.show()
    ø.$('#r_share').removeClass "r_active"
    false

  close: ->
    @intervals "clear"
    @model.intervals "clear"
    @$el.fadeOut 400, =>
      @$el.remove()
    false

  render: =>
    @$el.html(@template(@model.toJSON()))
    return this
