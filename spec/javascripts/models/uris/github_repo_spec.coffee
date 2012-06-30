#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "spec/models/uris/shared"
  "app/models/uris/github_repo"
], (shared, GitHubRepo) ->

  describe "Model", ->
    describe "URI", ->
      describe "GitHubRepo", ->

        beforeEach ->
          @urls = [
            "https://github.com/leppert/RMSN"
            "https://github.com/leppert/RMSN/"
          ]
          @model = new GitHubRepo string: @urls[0]

        shared()

        describe "#initialize()", ->
          it "should return the correct full_name after initialization", ->
            @model.get("full_name").should.equal("leppert/RMSN")

          it "should return the correct full_name after initialization with trailing slash", ->
            @model = new GitHubRepo string: @urls[1]
            @model.get("full_name").should.equal("leppert/RMSN")

        describe "#fetch()", ->
          it "should get data from the API", (done) ->
            @model.fetch 
              success: (model, response) ->
                model.get("description").should.equal("Reading Message Server")
                done()
              error: (model, response) ->
                throw response.responseText.data.message
