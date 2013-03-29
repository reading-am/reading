define [
  "app/views/uris/uri/view"
  "mustache"
  "app/init"
  "text!app/views/uris/github_repo/template.mustache"
], (URIView, Mustache, App, template) ->

  class GitHubRepoView extends URIView
    template: Mustache.compile template

    className: "r_url r_uri r_github_repo"

  App.Views.URIs.GitHubRepo = GitHubRepoView
  return GitHubRepoView
