#= require curl_config
#= require libs/curl

reading.curl [
  "app/models/uris/github_repo"
], (GitHubRepo) ->

  url = "https://github.com/leppert/RMSN"

  describe "GitHubRepo", ->

    describe "#initialize()", ->
      it "should return the correct full_name after initialization", ->
        model = new GitHubRepo string: url
        model.get("full_name").should.equal("leppert/RMSN")

      it "should return the correct full_name after initialization with trailing slash", ->
        model = new GitHubRepo string: "#{url}/"
        model.get("full_name").should.equal("leppert/RMSN")

    describe "#fetch()", ->
      it "should get data from the github.com API", (done) ->
        model = new GitHubRepo string: url
        model.fetch 
          success: ->
            done()
          error: (model, response) ->
            throw response.responseText.data.message
