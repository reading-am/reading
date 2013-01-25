define [
  "underscore"
  "libs/backbone"
  "app/init"
  "app/constants"
], (_, Backbone, App, Constants) ->

  # This is copied from Backbone's Model.prototype.url
  # Had trouble with recursion after minification when aliasing and overriding it
  Backbone.Model::endpoint = ->
    base = _.result(this, 'urlRoot') || _.result(this.collection, 'url') || throw new Error('A "url" property or function must be specified')
    if @isNew() then base else "#{base}#{if base.charAt(base.length-1) is "/" then "" else "/"}#{encodeURIComponent(@id)}"
  # Override the url method to append the absolute API route
  Backbone.Model::url = -> "//#{Constants.domain}/api/#{@endpoint()}"
  Backbone.Model::urlRoot = -> "#{@type.toLowerCase()}s"
  Backbone.Model::channel_name = -> @endpoint().replace(/\//g,".")

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

  # this reinstates a check in set() that was removed in 0.9.9
  # found here: https://github.com/documentcloud/backbone/blob/863814e519e630806096aa3ddeef520afbb263ff/backbone.js#L275
  Backbone.Model::_set = Backbone.Model::set
  Backbone.Model::set = (key, value, options) ->
    if key instanceof Backbone.Model
      key = key.attributes
    @_set key, value, options

  Backbone.Model::parse = (response) ->
    obj = if response[@type.toLowerCase()]? then response[@type.toLowerCase()] else response
    Backbone.Model::factory obj

  Backbone.Model::toJSON = (nested_to_id=true) ->
    Backbone.Model::deconstruct this, nested_to_id

  Backbone.Model::has_many = (name, type) ->
    type = name if !type?
    name = name.toLowerCase()
    @[name] = @nestCollection(name, App.Collections[type], @get(name))
    @[name].endpoint = => "#{@endpoint()}/#{name}"

    @_has_many = [] unless @_has_many?
    @_has_many.push name

  Backbone.Model::is_model = (input) ->
    input instanceof Backbone.Model or (_.isObject(input) and input.type? and input.id?)

  Backbone.Model::deconstruct = (input, nested_to_id) ->
    if _.isFunction input
      # Don't do anything here, just pass through
      # to account for _.isObject(function(){}) == true
    else if _.isArray input
      input = (Backbone.Model::deconstruct(val, nested_to_id) for val in input)
    else if _.isDate input
      input = _.ISODateString input
    else if _.isObject input
      if input instanceof Backbone.Model
        input = Backbone.Model::deconstruct _.clone(input.attributes), nested_to_id
      else
        for prop, val of input
          if nested_to_id
            if Backbone.Model::is_model val
              # has_one
              input["#{prop}_id"] = val.id if val.id?
              delete input[prop]
            else if _.isArray(val) and Backbone.Model::is_model(val[0])
              # has_many
              input["#{prop.slice(0,-1)}_ids"] = (i.id for i in val)
              delete input[prop]
          else
            input[prop] = Backbone.Model::deconstruct val, nested_to_id
    input

  return Backbone
