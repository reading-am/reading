reading.define [
  "jquery"
], ($) ->

  win_focus = true
  $(window).focus(-> win_focus = true).blur(-> win_focus = false)
  $.fn.hasFocus = -> win_focus

  return $
