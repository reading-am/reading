define [
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

    type = methodMap[method]
    options.dataType = "jsonp"
    options.data = {_method: type}
    options.data.token = reading.token if reading.token?

    if model && (method == 'create' || method == 'update')
      options.data.model = model.toJSON()

    if !options.url
      options.url = _.result(model, 'url') || urlError()

    options.error = if options.error? then options.error else (jqXHR, textStatus, errorThrown) ->
      alert "hey"
      _.log jqXHR, textStatus, errorThrown
      switch errorThrown
        when "Bad Request"
          alert Constants.errors.general
        when "Forbidden"
          alert Constants.errors.forbidden

    _success = if options.success? then options.success else _.log
    options.success = (data, textStatus, jqXHR) ->
      if data.meta.status < 400
        _success data, textStatus, jqXHR
      else
        jqXHR.status = data.meta.status
        jqXHR.responseText = data
        _.log "error!", jqXHR, textStatus, data.meta.msg, options.error
        options.error jqXHR, textStatus, data.meta.msg

    $.ajax options

  return Backbone
