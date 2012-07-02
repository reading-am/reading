#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "spec/models/uris/shared"
  "app/models/uris/wikipedia_article"
], (shared, WikipediaArticle) ->

  describe "Model", ->
    describe "URI", ->
      describe "WikipediaArticle", ->

        beforeEach ->
          @stub = "Tom_Cruise"
          @urls = [
            "http://en.wikipedia.org/wiki/#{@stub}"
            "http://es.wikipedia.org/wiki/Tom_Cruise"
            "http://en.wikipedia.org/wiki/Wikipedia:Unusual_articles"
            "http://en.wikipedia.org/wiki/Donaudampfschiffahrtselektrizit%C3%A4tenhauptbetriebswerkbauunterbeamtengesellschaft"
            "http://en.wikipedia.org/wiki/0.999..."
            "http://roa-tara.wikipedia.org/wiki/Pagene_Prengep%C3%A1le"
          ]
          @model = new WikipediaArticle string: @urls[0]

        shared()

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            @model.get("stub").should.equal(@stub)

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            @model.fetch 
              success: (model, response) ->
                model.get("title").should.equal("Tom Cruise")
                done()
              error: (model, response) ->
                throw response.responseText
