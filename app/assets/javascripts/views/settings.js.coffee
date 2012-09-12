reading.define [
  "jquery"
  "app/constants"
], ($, Constants) ->

  $ ->

    # ------- #
    # Signout #
    # ------- #

    $("#signout").on "click", ->
      confirm "Are you sure you want to sign out?"


    # ------------- #
    # User Deletion #
    # ------------- #

    $del = $("#user_delete a")
    org_text = $del.text()
    timer = false

    $del.on "click", ->

      if $del.hasClass "countdown"
        $del.text org_text
        $del.removeClass "countdown"
        clearInterval timer
        timer = false

      else if confirm "=== WARNING: Account Destruction Ahead ===\n\nYikes! Okay okay, well, then um… would you mind emailing greg@#{Constants.domain} to let me know why you want to be destroyed? I mean, you don't have to but it'd be nice to know.\n\nIf you wish to proceed, you should know that account destruction is permanent. It's final, irreversible, terminal and an all around bummer. In fact, I'd prefer you clicked \"Cancel\" and ended this foolishness right now.\n\nBut if you really must go through with it, this is also a good time to mention that you can export all your data from the \"extras\" tab.\n\nWhen you've made your peace and said your last words, click \"OK\" to begin ultimate destruction."
        $del.addClass "countdown"
        i = 5

        timer = setInterval ->
          if i >= 0
            $del.text "Self destruct in #{i--} (click to cancel)"
          else
            $.rails.handleMethod $del
        , 1000

      return false
