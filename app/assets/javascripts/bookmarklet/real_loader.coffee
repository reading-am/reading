#= require baseUrl

require [
  "underscore"
  "jquery"
  "app/constants"
  "app/models/post"
  "app/models/page"
  "app/views/bookmarklet/app"
  "app/helpers/bookmarklet"
  "app/collections/pages" # needs to be preloaded
  "app/collections/providers" # needs to be preloaded
  "text!bookmarklet/loader.css"
  "text!components/mentionsInput.css"
], (_, $, Constants, Post, Page, AppView, Helpers, Pages, Providers, css...) ->

  $("<style>").html(css.join " ").appendTo("head")

  #-----------------------------------------
  # Config Vars

  reading.ready = false
  on_reading = window.location.host.indexOf(Constants.domain) is 0 or
               window.location.host.indexOf("staging.#{Constants.domain}") is 0 or
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
    AppView::current.close() if AppView::current?

    Post::current = new Post
    AppView::current = new AppView model: Post::current if platform isnt "redirect"

    Post::current.save params, success: (model) ->
      if platform is "redirect"
        # forward back through to Reading so that the user's token doesn't show up in the referrer
        window.location = if window.location.href.indexOf('/t/') > -1 then "http://#{Constants.domain}/t/-/#{params.url}" else params.url
      else
        model.keep_fresh()

  get_url = ->
    selector = _.map(Page::meta_tag_namespaces, (namespace) -> "meta[property^='#{namespace}:url']").join(",")

    if url = Page::parse_canonical $("link[rel=canonical]").attr("href"), window.location.host, window.location.protocol
    else if url = Page::parse_canonical $(selector).attr("content"), window.location.host, window.location.protocol
    else
      url = window.location.href

    Page::parse_url(url)

  get_title = ->
    window.document.title

  # this has a Ruby companion in models/page.rb#populate_remote_data()
  get_head_tags = ->
    head_tags = null
    selector = _.map(Page::meta_tag_namespaces, (namespace) -> "meta[property^='#{namespace}:']").join(",")

    $(selector).each ->
      $this = $(this)

      head_tags = {} unless head_tags?
      prop = $this.attr("property")
      namespace = prop.split(":")[0]
      head_tags[namespace] = {} unless head_tags[namespace]?

      head_tags[namespace][prop.substr(namespace.length+1)] = $this.attr("content")

    head_tags

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
          return window.location = url
        else
          title = null
      else
        title = get_title()

      submit
        url: get_url()
        title: title
        referrer_id: reading.referrer_id ? 0
        head_tags: get_head_tags()


  #-----------------------------------------
  # Check the bookmarklet version

  up_to_date = ->
    !Constants.latest_versions[platform]? || String(version).replace(/\./g,'') >= String(Constants.latest_versions[platform]).replace(/\./g,'')

  #-----------------------------------------
  # Prompt to upgrade

  upgrade = -> $.getScript "//#{Constants.domain}/assets/bookmarklet/upgrade.js"

  #-----------------------------------------
  # Check for jQuery and initialize

  if up_to_date() then init() else upgrade()
