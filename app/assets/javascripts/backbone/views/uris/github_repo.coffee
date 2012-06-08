reading.define [
  "app/views/uris/uri"
  "handlebars"
  "app"
], (URIView, Handlebars, App) ->

  class GitHubRepoView extends URIView
    template: Handlebars.compile "
    {{#if id}}
      <div class=\"r_github_repo_full_name\">{{full_name}}</div>
      <div class=\"r_github_repo_description\">{{description}}</div>
    {{else}}
      Loading GitHub repo...
    {{/if}}
    "

    className: "r_url r_github_repo"

  App.Views.URIs.GitHubRepo = GitHubRepoView
  return GitHubRepoView
