define [
  "underscore"
  "jquery"
  "backbone"
  "text!app/views/components/titlecard/template.mustache"
  "text!app/views/components/titlecard/styles.css"
  "extend/jquery/waypoints.min"
], (_, $, Backbone, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class Titlecard extends Backbone.View
    @parse_template template

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
