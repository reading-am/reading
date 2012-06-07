reading.define [
  "jquery"
  "backbone"
  "handlebars"
], ($, Backbone, Handlebars) ->

  class TweetView extends Backbone.View
    template: Handlebars.compile "
    "

