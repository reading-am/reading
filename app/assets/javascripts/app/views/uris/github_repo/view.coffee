define [
  "underscore"
  "jquery"
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/github_repo/template.mustache"
  "text!app/views/uris/github_repo/styles.css"
], (_, $, URIView, App, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class GitHubRepoView extends URIView
    @parse_template template

    initialize: (options) ->
      load_css()
      super options

  App.Views.URIs.GitHubRepo = GitHubRepoView
  return GitHubRepoView
