define [
  "jquery"
  "backbone"
  "app/constants"
  "app/helpers/authorizations"
], ($, Backbone, Constants, AuthorizationsHelper) ->

  class UserEditView extends Backbone.View

    events:
      "keyup #user_password"  : "toggle_password_fields"
      "click #user_delete a"  : "destroy"

    initialize: ->
      # populate the auth spans with real usernames
      AuthorizationsHelper.populate_accounts "twitter", $(".provider.twitter .account")
      AuthorizationsHelper.populate_accounts "facebook", $(".provider.facebook .account")

    toggle_password_fields: ->
      @$user_password ?= $("#user_password")
      @$password_fields ?= $("#confirm_password_fields")

      if @$user_password.val()
        @$password_fields.slideDown()
      else
        @$password_fields.slideUp()

    destroy:(e) ->
      @$destroy       ?= $(e.currentTarget)
      @destroy_text   ?= @$destroy.text()
      @destroy_timer  ?= false

      if @$destroy.hasClass "countdown"
        @$destroy.text @destroy_text
        @$destroy.removeClass "countdown"
        clearInterval @destroy_timer
        @destroy_timer = false

      else if confirm "=== WARNING: Account Destruction Ahead ===\n\nYikes! Okay okay, well, then um… would you mind emailing greg@#{Constants.root_domain} to let me know why you want to be destroyed? I mean, you don't have to but it'd be nice to know.\n\nIf you wish to proceed, you should know that account destruction is permanent. It's final, irreversible, terminal and an all around bummer. In fact, I'd prefer you clicked \"Cancel\" and ended this foolishness right now.\n\nBut if you really must go through with it, this is also a good time to mention that you can export all your data from the \"extras\" tab.\n\nWhen you've made your peace and said your last words, click \"OK\" to begin ultimate destruction."
        @$destroy.addClass "countdown"
        i = 5

        @destroy_timer = setInterval =>
          if i >= 0
            @$destroy.text "Self destruct in #{i--} (click to cancel)"
          else
            $.rails.handleMethod @$destroy
        , 1000

      return false
