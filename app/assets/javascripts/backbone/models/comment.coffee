define [
  "backbone"
  "app/init"
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

    mentioned_usernames: ->
      TwitterText.extractMentions @get("body") || []

    mentioned_emails: ->
      @get("body").match(Constants.regexes.email) || []

    hashtags: ->
      TwitterText.extractHashtags @get("body")

    urls: ->
      TwitterText.extractUrls @get("body")

    is_a_show: ->
      m = @mentioned_usernames().join("@")
      m = "@#{m}" if m.length > 0
      m += @mentioned_emails().join('')
      return (m.length > 0 and @get("body").replace(/\s|,/g,"").length is m.length)


  App.Models.Comment = Comment
  return Comment
