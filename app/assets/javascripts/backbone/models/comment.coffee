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

    mentions: ->
      TwitterText.extractMentions @get("body")

    hashtags: ->
      TwitterText.extractHashtags @get("body")

    urls: ->
      TwitterText.extractUrls @get("body")

    is_a_show: ->
      m = @mentions()
      return (m.length > 0 and @get("body").trim() is "@#{m[0]}")

    is_a_multi_show: ->
      ###
      mention_count = @mentions().length
      word_count = @get("body").trim().split(' ').length 
      return (word_count is mention_count and mention_count > 1) 
      ###
      m = @mentions()
      b = @get("body").trim().split(' ')
      for index, word of b
        if word is not "@#{m[index]}" then return false
      return true

  App.Models.Comment = Comment
  return Comment
