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

$ ->
  $("a.external").on "click", ->
    $this = $(this)
    link_host = @href.split("/")[2]
    document_host = document.location.href.split("/")[2]
    base58_id = (if typeof $this.data("base58_id") isnt "undefined" then $this.data("base58_id") else "")
    unless link_host is document_host
      # old redirect method through reading url
      # pre = "http://#{document_host}/"+(base58_id ? "p/#{base58_id}/" : "")
      # window.open pre+this.href

      # new AJAX method - only log it if they're logged in
      if current_user.logged_in()
        $.ajax
          url: "/posts/create.json"
          data:
            url: @href
            referrer_id: (if base58_id then base58.decode(base58_id) else "")
      window.open @href
      false

  $(".bookmarklet").hover (->
    $this = $(this)
    $this.find("span").hide()
    $this.find("a").css "display", "block"
  ), ->
    # safari won't let you drag with this in place
    # $this = $(this)
    # $this.find("span").show()
    # $this.find("a").hide()

  $(".footnote").on "click", ->
    window.open $(this).data("url"), "footnote", "location=0,status=0,scrollbars=0,width=900,height=400"
    false

  # select search on page load
  $search = $("#search input")
  $search.focus() if $search.val()

  # trigger login from header
  $("a[data-provider]").on "click", ->
    $this = $(this)
    Prov = window["#{$this.data("provider")}Prov"]
    Prov::[$this.data("method")] (response) ->
      if response.authResponse
        window.location.reload true

    false
