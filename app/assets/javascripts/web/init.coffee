#= require baseUrl

require [
  "jquery"
  "libs/base58"
  "libs/indian"
  "app/init"
  "app/models/post"
  "app/models/user_with_current"
  "app/constants"
  "app/views/components/titlecard/view"
  "extend/jquery/rails"
  "extend/jquery/cookies"
  "extend/jquery/embedly"
], ($, base58, Indian, App, Post, User, Constants, Titlecard) ->

  $.embedly.defaults.key = Constants.embedly_key

  # write timezone info. From: http://stackoverflow.com/questions/942747/set-current-time-zone-in-rails
  unless $.cookie "timezone"
    current_time = new Date()
    $.cookie "timezone", current_time.getTimezoneOffset(),
      path: "/"
      expires: 10

  window.hasfocus = true
  $(window).focus(->
    window.hasfocus = true
  ).blur ->
    window.hasfocus = false

  # --------------------
  # doc ready
  $ ->

    new Titlecard el: $("#titlecard")

    framed = window.top isnt window
    $("body").addClass("framed") if framed

    $(".footnote").on "click", ->
      window.open $(this).data("url"), "footnote", "location=0,status=0,scrollbars=0,width=900,height=400"
      false

    # select search on page load
    $search = $("#search input")
    $search.focus() if $search.val()

    do_provider_method = (provider, method) ->
      uid = if method is "connect" then "new" else null
      auth = new App.Models["#{provider}Auth"](uid: uid)
      $('#loading').fadeIn()

      auth.login
        success: (response) =>
          window.location.reload true
        error: (response) ->
          $('#loading').hide()
          alert (Constants.errors[response.status] ? Constants.errors.generic).replace /{provider}/gi, provider

      false

    $("a[data-provider][data-method]").on "click", ->
      $this = $(this)
      do_provider_method $this.data("provider"), $this.data("method")

    $("#authorizations select").on "change", ->
      $this = $(this)
      do_provider_method $this.val(), $this.data("method")
      $this.val $this.find('option:first').val()


    $(".chrome-install").on "click", ->
      if /chrome/.test navigator.userAgent.toLowerCase()
        chrome.webstore.install()
        false

    $(".firefox-install").on "click", ->
      window.open($(this).attr("href"))
      false

  if Indian.is
    window.document.title = '✌ Reading'

    $(window).focus ->
      Indian.badge ""
      $(".post.new").fadeTo("medium", 1).removeClass("new")
