define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/github_repo/template.mustache"
], (URIView, App, template) ->

  class GitHubRepoView extends URIView
    @parse_template template

  App.Views.URIs.GitHubRepo = GitHubRepoView
  return GitHubRepoView
