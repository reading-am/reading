reading.define ["jquery"], ($) ->

  $ ->
    $("#signout").on "click", ->
      confirm "Are you sure you want to sign out?"
