define [
  "jquery"
  "backbone"
  "app/init"
  "app/constants"
  "app/collections/users"
  "app/collections/comments"
], ($, Backbone, App, Constants) ->

  class Page extends Backbone.Model
    type: "Page"

    initialize: ->
      @has_many "Users"
      @has_many "Posts"
      @has_many "Comments"

    parse_hostname: ->
      $("<a>", href: @get("url"))[0].hostname

    parse_root_domain: ->
      @parse_hostname().split(".")[-2..].join(".")

    verb: ->
      if @get("medium") is "audio"
        'listening to'
      else if @get("medium") is "video"
        'watching'
      else if @get("medium") is "image" or ['profile'].indexOf(@get("media_type")) isnt -1
        'looking at'
      else
        'reading'

  Page::meta_tag_namespaces = ['og','twitter']

  Page::parse_canonical = (canonical, host, protocol) ->
    domain = host.split(".")
    domain = "#{domain[domain.length-2]}.#{domain[domain.length-1]}"

    # twitter doesn't update the canonical on push state
    excluded_domains = ["twitter.com","instagram.com","hulu.com"]

    # this has a Ruby companion in app/models/page.rb#remote_canonical()
    if !canonical or
    excluded_domains.indexOf(domain) > -1
      canonical = false
    # protocol relative url
    else if canonical[0..1] is "//"
      canonical = "#{protocol}#{canonical}"
    # relative url
    else if canonical[0] is "/"
      canonical = "#{protocol}//#{host}#{canonical}"
    # sniff test for mangled urls
    else if canonical.indexOf("//") is -1 or
    # sniff test for urls on a different root domain
    canonical.indexOf(domain) is -1
      canonical = false

    canonical

  Page::parse_url = (url) ->
    regex = new RegExp "(?:https?:\/\/#{Constants.domain.replace(/\./g,"\\.")}\/(?:(?:p|t)\/[^\/]+\/)*)?(.+)"
    reg_url = regex.exec(url)[1]

    # don't lob off reading.am if they're reading a Reading page (a user profile, for instance)
    url = reg_url unless reg_url.indexOf('.') is -1
    # some browsers encode the colon if passed in the url
    url = url.replace(/^(https?)%3A\/\//, '$1://')
    # Add a protocol if it's missing
    url = "http://#{url}" if url.indexOf('://') is -1

    return url

  App.Models.Page = Page
  return Page
