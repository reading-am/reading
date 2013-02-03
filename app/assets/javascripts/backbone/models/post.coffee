define [
  "jquery"
  "backbone"
  "app/init"
  "app/constants"
  "libs/base58"
  "extend/jquery/win_focus"
], ($, Backbone, App, Constants, Base58) ->

  class Post extends Backbone.Model
    type: "Post"

    initialize: (options) ->
      @bind "destroy", => @intervals "clear"

    validate: (attr) ->
      if !attr.url || attr.url is "about:blank"
        return Constants.errors.general

    short_url: ->
      "#{Constants.short_domain}/p/#{Base58.encode(@id)}"

    # update the date_created every 15 seconds ala chartbeat
    # consider not doing this for context-menu posts
    keep_fresh: ->
      loading = false
      @intervals "add", 3, =>
        now = new Date
        if $(window).hasFocus() and not loading and now - @get("updated_at") >= 15000
          loading = true
          @save "updated_at", now, success: -> loading = false

  Post::parse_canonical = (canonical, host, protocol) ->
    domain = host.split(".")
    domain = "#{domain[domain.length-2]}.#{domain[domain.length-1]}"

    # twitter doesn't update the canonical on push state
    excluded_domains = ["twitter.com"]

    if !canonical or
    excluded_domains.indexOf(domain) > -1
      canonical = false
    # protocol relative url
    else if canonical.substr(0,2) is "//"
      canonical = "#{protocol}#{canonical}"
    # relative url
    else if canonical.substr(0,1) is "/"
      canonical = "#{protocol}//#{host}#{canonical}"
    # sniff test for mangled urls
    else if canonical.indexOf("//") is -1 or
    # sniff test for urls on a different root domain
    canonical.indexOf(domain) is -1
      canonical = false

    canonical


  Post::parse_url = (url) ->
    regex = new RegExp "(?:https?:\/\/#{Constants.domain.replace(/\./g,"\\.")}\/(?:(?:p|t)\/[^\/]+\/)*)?(.+)"
    reg_url = regex.exec(url)[1]

    # don't lob off reading.am if they're reading a Reading page (a user profile, for instance)
    url = reg_url unless reg_url.indexOf('.') is -1
    url = "http://#{url}" if url.indexOf('://') is -1

    return url

  App.Models.Post = Post
  return Post
