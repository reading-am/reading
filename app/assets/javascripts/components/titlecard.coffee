$ ->
  $card = $("#titlecard")

  $card.on "click", () ->
    if $(document).scrollTop() > 15
      $("body").animate {scrollTop : 0}
      false

  $card.on "mouseenter", () ->
    if $(document).scrollTop() > 15
      $card.find("strong").text "Go up."


  $card.on "mouseleave", () ->
    $card.find("strong").text "Reading"
