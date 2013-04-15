define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/github_repo/template.mustache"
  "text!app/views/uris/github_repo/styles.css"
], (URIView, App, template, styles) ->

  class GitHubRepoView extends URIView
    @assets
      styles: styles
      template: template

  App.Views.URIs.GitHubRepo = GitHubRepoView
  return GitHubRepoView
