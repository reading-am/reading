define [
  "underscore"
  "jquery"
  "backbone"
  "text!app/views/components/share_popover/styles.css"
  "extend/jquery/waypoints.min"
], (_, $, Backbone, css) ->

  class Titlecard extends Backbone.View
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

    events:
      "click": "scroll_to_top"

    initialize: ->
      load_css()

      $.waypoints.settings.scrollThrottle = 30
      $("body").waypoint (event, direction) =>
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
