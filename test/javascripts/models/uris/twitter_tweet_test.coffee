#= require curl_config
#= require libs/curl

reading.curl [
  "app/models/uris/twitter_tweet"
], (TwitterTweet) ->

  url = "https://twitter.com/leppert/status/206942518468808706"

  describe "Model", ->
    describe "URI", ->
      describe "TwitterTweet", ->

        describe "#regex", ->
          it "should successfully identify urls", ->
            TwitterTweet::regex.test(url).should.be.true

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            model = new TwitterTweet string: url
            model.get("id").should.equal("206942518468808706")

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            model = new TwitterTweet string: url
            model.fetch 
              success: (model) ->
                model.get("text").should.equal("Why am I the only one not making out with someone in front of this ice cream shop?")
                done()
              error: (model, response) ->
                throw response.responseText
