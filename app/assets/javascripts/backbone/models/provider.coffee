reading.define "app/models/provider", [
  "backbone"
  "app"
  "app/models/post"
  "app/models/comment"
], (Backbone, App, Post, Comment) ->

  class Provider extends Backbone.Model
    type: "Provider"

    run: -> @get("action").call this

    url: (vals) ->
      subject = @get("subject")
      if subject instanceof Post
        vals =
          url: subject.get("page").get("url")
          short_url: "http://#{subject.short_url()}"
          wrapped_url: subject.get("wrapped_url")
          title: "\"#{subject.get("page").get("title")}\""
      else if subject instanceof Comment
        vals =
          url: subject.get("url")
          short_url: "http://#{subject.short_url()}"
          wrapped_url: subject.get("url")
          title: "a comment by #{subject.get("user").get("display_name")} on \"#{subject.get("page").get("title")}\""

      parsed_url = @get("url_scheme")
      for val of vals
        parsed_url = parsed_url.replace("{{#{val}}}", encodeURIComponent(vals[val]))
      parsed_url

  App.Models.Provider = Provider
  return Provider
