reading.define [
  "jquery"
  "underscore"
  "libs/backbone"
  "app/constants"
], ($, _, Backbone, Constants) ->

  methodMap =
    create: 'POST',
    update: 'PUT',
    delete: 'DELETE',
    read:   'GET'

  Backbone._sync = Backbone.sync
  Backbone.sync = (method, model, options) ->
    _.log method, model, options

    options.type    ?= methodMap[method]
    options.url     ?= _.result(model, 'url') || urlError()
    options.data    ?= {}
    options.success ?= _.log
    options.error   ?= (jqXHR, textStatus, errorThrown) ->
      _.log jqXHR, textStatus, errorThrown
      switch errorThrown
        when "Bad Request"
          alert Constants.errors.general
        when "Forbidden"
          alert Constants.errors.forbidden

    if reading? and reading.token?
      options.data.token = reading.token

    if model && (method == 'create' || method == 'update')
      options.data.model = model.toJSON()

    is_xdr = /\/\/([A-Za-z0-9\-\.:]+)/.exec(options.url)[1] isnt window.location.host
    if is_xdr
      options.dataType = "jsonp"
      options.data._method = options.type

      _success = options.success
      options.success = (data, textStatus, jqXHR) ->
        if data.meta.status < 400
          _success data, textStatus, jqXHR
        else
          jqXHR.status = data.meta.status
          jqXHR.responseText = data
          options.error jqXHR, textStatus, data.meta.msg

    $.ajax options

  return Backbone
