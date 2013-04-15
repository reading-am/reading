define [
  "jquery"
  "backbone"
], ($, Backbone) ->

  class SettingsSubnavView extends Backbone.View

    events:
      "click #signout" : "signout"

    signout: ->
      confirm "Are you sure you want to sign out?"
