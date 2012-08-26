reading.define [
  "jquery"
  "app/constants"
], ($, Constants) ->

  $ ->
    $("#signout").on "click", ->
      confirm "Are you sure you want to sign out?"

    $del = $("#user_delete a")
    org_text = $del.text()
    timer = false

    $del.on "click", ->
      if $del.hasClass "countdown"
        $del.text org_text
        $del.removeClass "countdown"
        clearInterval timer
        timer = false

      else if confirm "Yikes! Okay okay, well, then um… would you mind emailing greg-and-max@#{Constants.domain} to let us know why? I mean, you don't have to but it'd be nice to know why you're breaking up with us.\n\nIf you wish to proceed, you should know that this is permanent. It's final, irreversible, terminal and an all around bummer. In fact, we'd prefer you clicked \"Cancel\" and ended this foolishness right now.\n\nBut if you really must go through with it, this is also a good time to mention that you can export your data from the \"extras\" tab.\n\nWhen you've made your peace and said your last words, click \"OK\" to begin ultimate destruction."
        $del.addClass "countdown"

        i = 5
        timer = setInterval ->
          if i >= 0
            $del.text "Self destruct in #{i--} (click to cancel)"
          else
            $.rails.handleMethod $del
        , 1000

      return false
