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

window.errors =
  generic: "There was an error processing your request. Sorry. You should try again and if you continue to have problems, contact me at hello@reading.am."
  AuthFailure: "Looks like we were unable to access your details from {provider}. Would you mind trying again?"
  AuthWrongAccount: "To modify that account, you'll need to log into it on {provider} and try again. At the moment you're logged into a different {provider} account."
  AuthPreexisting: "You tried to connect a new {provider} account but you're logged in to one of your existing {provider} accounts. Log in to the new account on {provider} and try again."
  AuthAdded: "Your {provider} account was added but you didn't give us the permissions we need to do what we need to do. Please try again."
  AuthTaken: "That {provider} account is connected to a different Reading account. If you remove it from the other Reading account, you'll be able to add it to this one."
  AuthSaveFail: "There was an error saving your account. Sorry. You should try again and if you continue to have problems, contact me at hello@reading.am."

$ ->
  $("a.external").on "click", ->
    $this = $(this)
    link_host = @href.split("/")[2]
    document_host = document.location.href.split("/")[2]
    base58_id = (if typeof $this.data("base58-id") isnt "undefined" then $this.data("base58-id") else "")
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

  $("a[data-provider][data-method]").on "click", ->
    $this = $(this)
    provider = $this.data("provider")
    uid = if $this.data("method") is "connect" then "new" else null
    auth = new window["#{provider}Auth"](uid)
    $('#loading').fadeIn()

    auth.login
      success: (response) =>
        window.location.reload true
      error: (response) ->
        $('#loading').hide()
        alert (errors[response.status] ? errors.generic).replace /{provider}/gi, provider

    false

  $(".chrome-install").on "click", ()->
    if /chrome/.test navigator.userAgent.toLowerCase()
      chrome.webstore.install()
      false
