define [
  "jquery"
  "underscore"
  "libs/backbone"
  "app/constants"
  "extend/jquery/xhr_cors_patch"
], ($, _, Backbone, Constants) ->

  methodMap =
    create: 'POST',
    update: 'PATCH',
    patch:  'PATCH',
    delete: 'DELETE',
    read:   'GET'

  add_data = (data, name, val) ->
    if _.isObject name
      add_data(data, k, v) for k, v of name
    else if data instanceof FormData
      if _.isObject val
        data.append("#{name}[#{k}]", v) for k, v of val
      else
        data.append name, val
    else
      data[name] = val

  Backbone._sync = Backbone.sync
  Backbone.sync = (method, model, options) ->
    _.log method, model, options

    # if you don't clone the options, they'll be modified and used by
    # BB to instantiate the objects and the url prop will be overwritten
    options = if options then _.clone(options) else {}
    _.defaults options,
      type: methodMap[method]
      url: _.result(model, 'url') || throw new Error 'A "url" property or function must be specified'
      data: {}
      success: _.log
      error: (jqXHR, textStatus, errorThrown) ->
        _.log jqXHR, textStatus, errorThrown
        switch errorThrown
          when "Bad Request"
            alert Constants.errors.general
          when "Forbidden"
            alert Constants.errors.forbidden

    if reading?.token?
      add_data options.data, "token", reading.token

    if model
      # in a collection, params contains limit, offset, etc
      if mp = _.result model, "params"
        add_data options.data, mp
      if (method == "create" || method == "update" || method is "patch")
        add_data options.data, "model", (options.attrs || model.toJSON())

    domain = /\/\/([A-Za-z0-9\-\.:]+)/.exec(options.url)[1]
    is_xdr = domain isnt window.location.host
    domain_cors = domain is Constants.domain

    if is_xdr
      if $.support.cors and domain_cors
        options.xhrFields ?= withCredentials: true
      else
        options.dataType = "jsonp"
        add_data options.data, "_method", options.type

        _success = options.success
        options.success = (data, textStatus, jqXHR) ->
          if data.meta.status < 400
            data = if data.response? then data.response else {}
            _success data, textStatus, jqXHR
          else
            jqXHR.status = data.meta.status
            jqXHR.responseText = data
            options.error jqXHR, textStatus, data.meta.msg

    xhr = Backbone.ajax options
    model.trigger 'request', model, xhr, options
    return xhr

  return Backbone
