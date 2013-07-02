define [
  "support/chai"
  "underscore"
], (chai, _) -> ->
  chai.should()

  describe "#regex", ->
    it "should successfully identify urls", ->
      _.each @urls, (url) =>
        @model.regex.test(url).should.be.true
