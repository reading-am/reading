reading.define "app/models/uris/github_repo", [
  "underscore"
  "jquery"
  "app"
  "app/models/uri"
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

      _success = if options.success? then options.success else _.log
      options.success = (data, textStatus, jqXHR) ->
        _success data.data, textStatus, jqXHR

      $.ajax options

  App.Models.URIs.GitHubRepo = GitHubRepo
  return GitHubRepo
