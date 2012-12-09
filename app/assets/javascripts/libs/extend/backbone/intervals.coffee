define [
  "underscore",
  "libs/backbone"
], (_, Backbone) ->

  Backbone.Model::intervals = Backbone.Collection::intervals = Backbone.View::intervals = (command, secs, fn) ->
    @_intervals = [] if _.isUndefined @_intervals
    switch command
      when "clear"
        _.each @_intervals, (id) -> clearInterval id
        @_intervals = []
      when "add"
        @_intervals.push setInterval fn, secs*1000

  return Backbone
