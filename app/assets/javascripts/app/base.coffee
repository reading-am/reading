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

window.base58 = libs.encdec()

# --------------------
# doc ready
$ ->

  framed = window.top isnt window
  $("body").addClass("framed") if framed

  $("a.external").on "click", ->
    $this = $(this)
    link_host = @href.split("/")[2]
    document_host = document.location.href.split("/")[2]
    base58_id = (if typeof $this.data("base58-id") isnt "undefined" then $this.data("base58-id") else "")
    if link_host isnt document_host
      if framed
        pre = "//#{document_host}/"+(if base58_id then "p/#{base58_id}/" else "")
        window.top.location = pre+@href
      else
        if current_user.logged_in()
          $.ajax
            url: "/posts/create.json"
            data:
              url: @href
              referrer_id: (if base58_id then base58.decode(base58_id) else "")
        window.open @href
      false

  $(".footnote").on "click", ->
    window.open $(this).data("url"), "footnote", "location=0,status=0,scrollbars=0,width=900,height=400"
    false

  # select search on page load
  $search = $("#search input")
  $search.focus() if $search.val()

  do_provider_method = (provider, method) ->
    uid = if method is "connect" then "new" else null
    auth = new window["#{provider}Auth"](uid)
    $('#loading').fadeIn()

    auth.login
      success: (response) =>
        window.location.reload true
      error: (response) ->
        $('#loading').hide()
        alert (Errors[response.status] ? Errors.generic).replace /{provider}/gi, provider

    false

  $("a[data-provider][data-method]").on "click", ->
    $this = $(this)
    do_provider_method $this.data("provider"), $this.data("method")

  $("#authorizations select").on "change", ->
    $this = $(this)
    do_provider_method $this.val(), $this.data("method")
    $this.val $this.find('option:first').val()


  $(".chrome-install").on "click", ()->
    if /chrome/.test navigator.userAgent.toLowerCase()
      chrome.webstore.install()
      false

  $(".firefox-install").on "click", ()->
    window.open($(this).attr("href"))
    false
