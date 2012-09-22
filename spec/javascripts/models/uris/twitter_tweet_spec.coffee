#= require require
#= require baseUrl
#= require ./shared

require [
  "spec/models/uris/shared"
  "app/models/uris/twitter_tweet"
], (shared, TwitterTweet) ->

  describe "Model", ->
    describe "URI", ->
      describe "TwitterTweet", ->

        beforeEach ->
          @id = "206942518468808706"
          @urls = [
            "https://twitter.com/leppert/status/#{@id}"
            "https://twitter.com/hamsandwich/status/211850281774874626/"
          ]
          @model = new TwitterTweet string: @urls[0]

        shared()

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            @model.get("id").should.equal(@id)

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            @model.fetch 
              success: (model, response) ->
                model.get("text").should.equal("Why am I the only one not making out with someone in front of this ice cream shop?")
                done()
              error: (model, response) ->
                throw response.responseText
