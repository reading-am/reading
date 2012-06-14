reading.define [
  "jquery"
  "app"
  "app/models/uris/uri"
  "plugins/truncate"
], ($, App, URI) ->

  class WikipediaArticle extends URI
    type: "WikipediaArticle"
    regex: /[A-Za-z\-]+\.wikipedia\.org\/wiki\/(.*)/

    initialize: (options) ->
      @set "stub", @regex.exec(options.string)[1]

    sync: (method, model, options) ->
      options.dataType = "jsonp"
      # from: http://stackoverflow.com/questions/964454/how-to-use-wikipedia-api-if-it-exists
      options.url = "https://en.wikipedia.org/w/api.php?action=query&prop=extracts&titles=#{@get("stub")}&format=json&exintro=1"
      $.ajax options

    parse: (response) ->
      data = response.query.pages
      for own key, val of data
        data = val

      data.id = data.pageid
      delete data.pageid

      $ex = $("<div>").html(data.extract).truncate(max_length: 250)
      data.short_extract = $ex.html()

      return data

  App.Models.URIs.WikipediaArticle = WikipediaArticle
  return WikipediaArticle
