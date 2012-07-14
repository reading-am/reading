define [
  "app/views/uris/uri"
  "handlebars"
  "app/init"
], (URIView, Handlebars, App) ->

  class InstagramImageView extends URIView
    template: Handlebars.compile "
    {{#if url}}
      <img src=\"{{url}}\">
      <div class=\"r_instagram_image_info\">
        <img class=\"r_icon\" src=\"https://instagr.am/favicon.ico\">
        <span>{{author_name}}</span>
        : <span class=\"r_instagram_image_title\">{{title}}</span>
      </div>
    {{else}}
      Loading Instagram image...
    {{/if}}
    "

    className: "r_url r_uri r_instagram_image"

  App.Views.URIs.InstagramImage = InstagramImageView
  return InstagramImageView
