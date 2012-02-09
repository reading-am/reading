$ ->
  $card = $("#titlecard")

  $card.on "click", ->
    unless $card.find("strong").text() is "Reading"
      $("body").animate {scrollTop : 0}
      false

  $.waypoints.settings.scrollThrottle = 30
  $("#mainnav").waypoint (event, direction) ->
    $card.find("strong").text if direction is "down" then "Go up" else "Reading"
  , {offset:-100}
