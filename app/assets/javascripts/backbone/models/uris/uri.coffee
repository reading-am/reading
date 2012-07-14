reading.define [
  "underscore"
  "backbone"
  "app/init"
], (_, Backbone, App) ->

  class URI extends Backbone.Model
    type: "URI"

    initialize: (options) ->
      @set "id", @regex.exec(options.string)[1]


  URI::factory = (string) ->
    u = _.find App.Models.URIs, (uri) -> uri::regex.test string
    new App.Models.URIs[u::type] string: string if u?

  App.Models.URI = URI
  App.Models.URIs = {}
  return URI
