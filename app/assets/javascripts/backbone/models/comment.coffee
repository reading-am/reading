reading.define [
  "backbone"
  "app"
  "app/constants"
  "libs/base58"
], (Backbone, App, Constants, Base58) ->

  class Comment extends Backbone.Model
    type: "Comment"
    validate: (attr) ->
      if !attr.body || (!attr.page and !attr.page_id)
        return Constants.errors.general

    short_url: ->
      "#{Constants.short_domain}/c/#{Base58.encode(@id)}"

  App.Models.Comment = Comment
  return Comment
