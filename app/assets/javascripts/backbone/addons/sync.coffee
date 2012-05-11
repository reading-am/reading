methodMap =
  create: 'POST',
  update: 'PUT',
  delete: 'DELETE',
  read:   'GET'

ø.Backbone._sync = ø.Backbone.sync
ø.Backbone.sync = (method, model, options) ->
  ø._.log method, model, options

  type = methodMap[method]
  options.dataType = "jsonp"
  options.data = {_method: type}
  options.data.token = reading.token if reading.token?

  if model && (method == 'create' || method == 'update')
    options.data.model = model.toJSON()

  if !options.url
    options.url = ø._.result(model, 'url') || urlError()

  ø.$.ajax options
