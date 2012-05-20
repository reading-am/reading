define [
  "jquery"
  "plugins/color.min"
], ($) ->

  $ ->

    pulse = (el, c1, c2) ->
      $el = $(el)
      $el.animate {'background-color': c1}, 'slow', ->
        $el.animate({'background-color': c2}, 'slow', pulse($el, c1, c2))

    $('.post.active a.external').each -> pulse(this, '#FFF461', '#FFFBCC')
