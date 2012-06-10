reading.define [
  "underscore"
  "jquery"
  "app"
  "app/models/uris/uri"
], (_, $, App, URI) ->

  class GitHubRepo extends URI
    type: "GitHubRepo"
    regex: /github\.com\/([^\/]+)\/([^\/]+)/

    initialize: (options) ->
      bits = @regex.exec(options.string)
      @set "full_name", "#{bits[1]}/#{bits[2]}"

    sync: (method, model, options) ->
      options.dataType = "jsonp"
      options.url = "https://api.github.com/repos/#{@get "full_name"}"

      options.error = if options.error? then options.error else _.log

      _success = if options.success? then options.success else _.log
      options.success = (data, textStatus, jqXHR) ->
        if data.meta.status < 400
          _success data.data, textStatus, jqXHR
        else
          jqXHR.status = data.meta.status
          jqXHR.responseText = data
          options.error jqXHR, textStatus, data.data.message

      $.ajax options

  App.Models.URIs.GitHubRepo = GitHubRepo
  return GitHubRepo
