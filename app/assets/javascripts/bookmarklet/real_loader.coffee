#= require baseUrl

require [
  "jquery"
  "app/constants"
  "app/models/post"
  "app/views/bookmarklet/app"
  "app/helpers/bookmarklet"
  "app/collections/pages" # needs to be preloaded
  "app/collections/providers" # needs to be preloaded
  "text!bookmarklet/loader.css"
  "text!components/mentionsInput.css"
], ($, Constants, Post, AppView, Helpers, Pages, Providers, css...) ->

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

      url = Post::parse_url window.location.href

      if platform is "redirect"
        if token is "-" or !token
          return window.location = url
        else
          title = null
      else
        title = window.document.title

      submit
        url: url
        title: title
        referrer_id: reading.referrer_id ? 0


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