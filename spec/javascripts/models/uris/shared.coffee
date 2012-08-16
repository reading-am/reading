define "spec/models/uris/shared", [
  "underscore"
], (_) -> ->

  describe "#regex", ->
    it "should successfully identify urls", ->
      _.each @urls, (url) =>
        @model.regex.test(url).should.be.true
