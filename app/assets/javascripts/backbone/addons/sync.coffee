define [
  "jquery",
  "underscore",
  "libs/backbone"
], ($, _, Backbone) ->

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

    $.ajax options

  return Backbone
