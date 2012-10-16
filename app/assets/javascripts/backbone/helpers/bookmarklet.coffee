define [
  "app/constants"
], (Constants) ->

  # for validating general posting of urls
  validate_post_url: (url) ->
    # don't post on oauth pages
    url.indexOf('/oauth/') is -1 and
    # don't post on pages with oauth tokens
    !url.match(/oauth_token/i)

  # for validating auto-posting via the extensions
  validate_ref_url: (url) ->
    # let non-Reading urls pass through, accounting for http and https
    (url.indexOf(Constants.domain) isnt 7 and url.indexOf(Constants.domain) isnt 8) or
    # exclude settings sections
    url.indexOf('/settings/') is -1 and
    # exclude auth sections
    url.indexOf('/auth/') is -1
