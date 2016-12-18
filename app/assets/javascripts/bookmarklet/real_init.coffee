#= require baseUrl

require [
  "underscore"
  "jquery"
  "app/constants"
  "app/models/post"
  "app/models/user"
  "app/models/page"
  "app/views/bookmarklet/app/view"
  "app/helpers/bookmarklet"
  "app/collections/pages" # needs to be preloaded
  "app/collections/providers" # needs to be preloaded
  "text!bookmarklet/init.css"
], (_, $, Constants, Post, User, Page, BookmarkletAppView, Helpers, Pages, Providers, css) ->

  $("<style>").html(css).appendTo("head")

  #-----------------------------------------
  # Config Vars

  if reading.bypass_cf
    Constants.domain = "#{Constants.domain.replace("www.","").split(".").slice(0,-1).reverse().join("-")}.herokuapp.com"

  reading.ready = false
  on_reading = window.location.host.indexOf(Constants.domain) is 0 or
               window.location.host.indexOf("staging.#{Constants.root_domain}") is 0 or
               window.location.host.indexOf("0.0.0.0") is 0
  token = reading.token ? null
  platform = reading.platform ? (if on_reading then "redirect" else "bookmarklet")
  version = reading.version ? "0.0.0"

  #-----------------------------------------
  # Submit the post

  reading.submit = submit = (params) ->
    # do a quick sanity check on the url
    return unless Helpers.validate_post_url(params.url) and Helpers.validate_ref_url(document.referrer)

    # clear old items from previous posts
    Post::current.intervals "clear" if Post::current?
    BookmarkletAppView::current.close() if BookmarkletAppView::current?

    Post::current = new Post
    # This must be bound before the BookmarkletAppView is instantiated and binds its events
    Post::current.bind "change:id", -> User::current = @get("user")

    BookmarkletAppView::current = new BookmarkletAppView model: Post::current if platform isnt "redirect"

    Post::current.save params, success: (model) ->
      if platform is "redirect"
        # forward back through to Reading so that the user's token doesn't show up in the referrer
        window.location = if window.location.href.indexOf('/t/') > -1 then "#{Constants.root_url}/t/-/#{params.url}" else params.url
      else
        # Describe couldn't get the page for some reason
        # so send a snapshot of the HTML for processing
        page = model.get("page")
        if !page.get("has_describe_data")
          $html = $("html").clone()
          $html.find("script, style").remove()
          page.save {html: $html.html()}, patch: true

  # this has a Ruby companion in models/page.rb#remote_canonical_url()
  get_url = ->
    # if there's a hashbang, don't use the canonical link because
    # it's usually not updated as the hashbang is changed
    if window.location.href.indexOf("#!") > -1
      url = window.location.href
    else
      selector = _.map(Page::meta_tag_namespaces, (namespace) -> "meta[property^='#{namespace}:url']").join(",")

      if url = Page::parse_canonical $("link[rel=canonical]").attr("href"), window.location.host, window.location.protocol
      else if url = Page::parse_canonical $(selector).attr("content"), window.location.host, window.location.protocol
      else url = window.location.href

    Page::parse_url(url)

  get_title = ->
    # if there's a hashbang, don't use the title metagtags since
    # they're usually not updated as the hashbang is changed
    if window.location.href.indexOf("#!") > -1
      title = window.document.title
    else
      if title = $("meta[property='og:title']").attr("content")
      else if title = $("meta[property='twitter:title']").attr("content")
      else if title = $("meta[name='title']").attr("content")
      else title = window.document.title

    title

  get_desc = ->
    if desc = $("meta[property='og:description']").attr("content")
    else if desc = $("meta[property='twitter:description']").attr("content")
    else desc = $("meta[name='description']").attr("content")

    desc

  #-----------------------------------------
  # Initialize!

  init = ->
    # fire an event to let people know reading is ready
    # can't seem to use jquery.trigger for events attached
    # without jquery
    e = document.createEvent "Event"
    e.initEvent "reading.ready", true, true
    document.dispatchEvent e
    reading.ready = true

    if platform is "redirect" or platform is "bookmarklet"

      if platform is "redirect"
        if token is "-" or !token
          return window.location = get_url()
        else
          title = null
      else
        title = get_title()
        desc = get_desc()

      submit
        url: reading.url || get_url()
        title: title
        description: desc
        referrer_post_id: reading.referrer_post_id ? 0


  #-----------------------------------------
  # Check the bookmarklet version

  up_to_date = ->
    !Constants.latest_versions[platform]? || String(version).replace(/\./g,'') >= String(Constants.latest_versions[platform]).replace(/\./g,'')

  #-----------------------------------------
  # Prompt to upgrade

  upgrade = -> $.getScript "#{Constants.root_url}/assets/bookmarklet/upgrade.js"

  #-----------------------------------------
  # Check for jQuery and initialize

  if up_to_date() then init() else upgrade()
