define [
  "support/chai"
  "app/constants"
  "app/helpers/bookmarklet"
], (chai, Constants, Helpers) ->
  chai.should()

  describe "Helper", ->
    describe "Bookmarklet", ->

      beforeEach ->
        @local_urls = [
          "http://#{Constants.domain}/testing"
          "https://#{Constants.domain}/testing"
        ]
        @random_urls = [
          "https://www.google.com/"
          "http://www.amazon.com/Jim-Beam-Barbecue-Sunflower-5-15-Ounce/dp/B000VDL7RG/ref=sr_1_5?s=grocery&ie=UTF8&qid=1350357784&sr=1-5&keywords=bigs+sunflower+seeds"
          "http://grooveshark.com/#!/album/Reunion+Tour/139714"
          "https://example.com/testing"
        ]

      describe "#validate_post_url()", ->
        it "should successfully approve urls", ->
          Helpers.validate_post_url(url).should.be.true for url in @local_urls
          Helpers.validate_post_url(url).should.be.true for url in @random_urls

        it "should successfully reject urls", ->
          urls = [
            "https://example.com/oauth/testing"
            "https://example.com/testing?oauth_token=1234"
            "https://www.evernote.com/Login.action?targetUrl=%2FOAuth.action%3Foauth_token%3Dreading-am.13A69A3630D.687474703A2F2F72656164696E672E616D2F617574682F657665726E6F74652F63616C6C6261636B.318B3B5BC9D69B36D50198FD79A2FA05"
          ]
          Helpers.validate_post_url(url).should.be.false for url in urls

      describe "#validate_ref_url()", ->
        it "should successfully approve urls", ->
          Helpers.validate_ref_url(url).should.be.true for url in @local_urls
          Helpers.validate_ref_url(url).should.be.true for url in @random_urls

        it "should successfully reject urls", ->
          urls = [
            "http://#{Constants.domain}/settings/hooks"
            "https://#{Constants.domain}/auth/loading/evernote"
          ]
          Helpers.validate_ref_url(url).should.be.false for url in urls
