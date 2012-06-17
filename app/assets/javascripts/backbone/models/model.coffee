reading.define [
  "underscore"
  "libs/backbone"
  "app"
  "app/constants"
], (_, Backbone, App, Constants) ->

  # Override the url method to append the absolute API route
  Backbone.Model::_url = Backbone.Model::url
  Backbone.Model::url = -> "//#{Constants.domain}/api/#{@_url()}"

  Backbone.Model::factory = (input) ->
    if _.isArray input
      input = (Backbone.Model::factory val for val in input)
      if _.isObject input[0] and input[0].type? and _.isFunction App.Collections["#{input[0].type}s"]
        input = new App.Collections["#{input[0].type}s"](input)
    else if input instanceof Object and (input not instanceof Backbone.Model and input not instanceof Backbone.Collection)
      for prop, val of input
        if prop is "created_at" or prop is "updated_at"
          input[prop] = new Date val
        else
          input[prop] = Backbone.Model::factory val
      if input.type? and _.isFunction App.Models[input.type]
        input = new App.Models[input.type](input)
    input

  Backbone.Model::urlRoot = ->
    "#{@type.toLowerCase()}s"

  Backbone.Model::parse = (response) ->
    obj = if response? then response[@type.toLowerCase()] else response
    Backbone.Model::factory obj

  Backbone.Model::toJSON = ->
    obj = _.clone @attributes
    Backbone.Model::deconstruct obj

  Backbone.Model::has_many = (name, type) ->
    type = name if !type?
    name = name.toLowerCase()
    @[name] = @nestCollection(name, App.Collections[type], @get(name))
    @[name].url = => "#{@url()}/#{name}"

  # converts nested Backbone objects to simply an id reference
  Backbone.Model::deconstruct = (input) ->
    if _.isFunction input
      # Don't do anything here, just pass through.
      # For whatever reason, _.isObject(function(){}) == true
    else if _.isArray input
      input = (Backbone.Model::deconstruct val for val in input)
    else if _.isDate input
      input = _.ISODateString input
    else if _.isObject input
      for prop, val of input
        if val instanceof Backbone.Model
          input["#{prop}_id"] = val.get("id") if val.get("id")
          delete input[prop]
        else
          input[prop] = Backbone.Model::deconstruct val
    input

  Backbone.Model::intervals = Backbone.Collection::intervals = Backbone.View::intervals = (command, secs, fn) ->
    @_intervals = [] if _.isUndefined @_intervals
    switch command
      when "clear"
        _.each @_intervals, (id) -> clearInterval id
        @_intervals = []
      when "add"
        @_intervals.push setInterval fn, secs*1000

  return Backbone
