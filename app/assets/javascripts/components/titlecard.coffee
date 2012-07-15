define [
  "jquery"
  "extend/jquery/waypoints.min"
], ($) ->

  $ ->
    $card = $("#titlecard")
    $links = $("#colinks", $card)

    $card.on "click", ->
      unless $card.find("strong").text() is "Reading"
        $(if $.browser.webkit then "body" else "html").animate {scrollTop : 0}
        false

    $.waypoints.settings.scrollThrottle = 30
    $("body").waypoint (event, direction) ->
      if direction is "down"
        $card.find("strong").text "Go up"
        $links.css({opacity:0})
      else
        $card.find("strong").text "Reading"
        $links.css({opacity:1})
    , {offset:-200}
