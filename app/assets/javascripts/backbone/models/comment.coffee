reading.define [
  "backbone"
  "app"
  "app/constants"
  "libs/base58"
  "libs/twitter-text"
], (Backbone, App, Constants, Base58, TwitterText) ->

  class Comment extends Backbone.Model
    type: "Comment"
    validate: (attr) ->
      if !attr.body || (!attr.page and !attr.page_id)
        return Constants.errors.general

    short_url: ->
      "#{Constants.short_domain}/c/#{Base58.encode(@id)}"

    mentions: ->
      TwitterText.extractMentions @get("body")

    hashtags: ->
      TwitterText.extractHashtags @get("body")

    urls: ->
      TwitterText.extractUrls @get("body")

    is_a_show: ->
      m = @mentions()
      return (m.length > 0 and @get("body").trim() is "@#{m[0]}")


  App.Models.Comment = Comment
  return Comment
