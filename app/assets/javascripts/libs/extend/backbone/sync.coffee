define [
  "jquery"
  "underscore"
  "libs/backbone"
  "app/constants"
  "extend/jquery/xhr_cors_patch"
], ($, _, Backbone, Constants) ->

  methodMap =
    create: 'POST',
    read:   'GET',
    update: 'PATCH',
    delete: 'DELETE'

  Backbone._sync = Backbone.sync
  Backbone.sync = (method, model_or_coll, _options) ->
    _.log method, model_or_coll, options

    # if you don't clone the options, they'll be modified and used by
    # BB to instantiate the objects and the url prop will be overwritten
    options         = _.clone _options

    options.type    ?= methodMap[method]
    options.url     ?= _.result(model_or_coll, 'url') || throw new Error 'A "url" property or function must be specified'
    options.data    ?= {}
    options.success ?= _.log
    options.error   ?= (jqXHR, textStatus, errorThrown) ->
      _.log jqXHR, textStatus, errorThrown
      switch errorThrown
        when "Bad Request"
          alert Constants.errors.general
        when "Forbidden"
          alert Constants.errors.forbidden

    if reading?.token?
      options.data.token = reading.token

    if model_or_coll
      if mp = _.result model_or_coll, "params"
        _.extend options.data, mp
      if (method == 'create' || method == 'update')
        options.data.model = model_or_coll.toJSON()

    domain = /\/\/([A-Za-z0-9\-\.:]+)/.exec(options.url)[1]
    is_xdr = domain isnt window.location.host
    domain_cors = domain is Constants.domain

    if is_xdr
      if $.support.cors and domain_cors
        options.xhrFields ?= withCredentials: true
      else
        options.dataType = "jsonp"
        options.data._method = options.type

        _success = options.success
        options.success = (data, textStatus, jqXHR) ->
          if data.meta.status < 400
            data = if data.response? then data.response else {}
            _success data, textStatus, jqXHR
          else
            jqXHR.status = data.meta.status
            jqXHR.responseText = data
            options.error jqXHR, textStatus, data.meta.msg

    $.ajax options

  return Backbone
