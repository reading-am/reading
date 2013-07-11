define [
  "jquery"
  "backbone"
  "text!app/views/components/titlecard/template.mustache"
  "text!app/views/components/titlecard/styles.css"
  "extend/jquery/waypoints"
], ($, Backbone, template, styles) ->

  class Titlecard extends Backbone.View
    @assets
      styles: styles
      template: template

    events:
      "click": "scroll_to_top"

    initialize: ->
      $("body").waypoint (direction) =>
        if direction is "down"
          txt = "Go up"
          opc = 0
        else
          txt = "Reading"
          opc = 1
        @$el.find("strong").text txt
        @$("#colinks").css({opacity:opc})
      , {offset:-200}

    scroll_to_top: ->
      if @$el.find("strong").text() isnt "Reading"
        $(if $.browser.webkit then "body" else "html").animate {scrollTop : 0}
        false
