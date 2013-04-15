define ["jquery"], ($) ->

  # replace external account ids with their usernames
  populate_accounts: (provider, selection) ->
    # endpoints to get user data from each provider
    api_urls =
      twitter: "https://api.twitter.com/1/users/show.json?id="
      facebook: "https://graph.facebook.com/"

    selection.each ->
      $this = $(this)
      unless isNaN $this.text()
        $.ajax
          url: api_urls[provider] + $this.text()
          dataType: "jsonp"
          success: (r) ->
            if r.screen_name
              $this.text (if provider is "twitter" then "@" else "") + r.screen_name
            else if r.username
              $this.text r.username
            else $this.text r.name  if r.name
