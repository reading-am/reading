class ø.Models.Provider extends ø.Backbone.Model
  type: "Provider"
  url: (post) ->
    vals =
      url: post.get("page").get("url")
      short_url: "http://#{post.short_url()}"
      wrapped_url: post.get("wrapped_url")
      title: post.get("page").get("title")
    parsed_url = @get("url_scheme")
    for val of vals
      parsed_url = parsed_url.replace("{{#{val}}}", encodeURIComponent(vals[val]))
    parsed_url

class ø.Collections.Providers extends ø.Backbone.Collection
  type: "Providers"
  model: ø.Models.Provider
