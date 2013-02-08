#= require require
#= require baseUrl
#= require ./shared

require [
  "underscore"
  "app/constants"
  "spec/models/shared"
  "app/models/page"
], (_, Constants, shared, Page) ->

  describe "Model", ->
    describe "Page", ->

      beforeEach ->
        @model = new Page id: 1140

      shared
        methods: ["read"]
        type: Page

      describe "#parse_canonical()", ->

        url = "/test/path"
        host = "example.com"
        protocol = "https:"
        href = "#{protocol}//#{host}#{url}" # what window.location.href would be

        it "should return false for an undefined canonical property", ->
          Page::parse_canonical(undefined, host, protocol).should.be.false

        it "should return false for excluded domains", ->
          Page::parse_canonical(url, "twitter.com", protocol).should.be.false

        it "should add the protocol for protocol agnostic urls", ->
          Page::parse_canonical("//#{host}#{url}", host, protocol).should.equal(href)

        it "should add the protocol and host for relative urls", ->
          Page::parse_canonical(url, host, protocol).should.equal(href)

        it "should return false for strings that aren't urls", ->
          Page::parse_canonical("this isnt a proper url", host, protocol).should.be.false

        it "should return false for canonical urls that point to a different root domain", ->
          Page::parse_canonical("http://google.com/test", host, protocol).should.be.false

      describe "#parse_url()", ->

        scenarios = [
          ""
          "http://#{Constants.domain}/"
          "http://#{Constants.domain}/p/AaBb123/"
          "http://#{Constants.domain}/t/AaBb123/"
          "http://#{Constants.domain}/t/AaBb123/p/AaBb123/"
          "http://#{Constants.domain}/p/AaBb123/t/AaBb123/"
          "http://#{Constants.domain}/t/-/p/AaBb123/"
          "http://#{Constants.domain}/p/AaBb123/t/-/"
        ]
        urls = [
          "http://www.google.com"
          "https://www.google.com/search?rlz=1C1CHFA_enUS484US484&aq=f&sugexp=chrome,mod=12&sourceid=chrome&ie=UTF-8&q=this+is+a+test"
          "http://mashable.com/2012/06/11/the-oatmeal-funnyjunk/"
          "http://home.pipeline.com/~hbaker1/Iterator.html"
          "http://alexobenauer.com/blog/2012/06/11/the-new-retina-display-macbook-pro-a-downgrade-from-my-current-macbook-pro/"
          "http://www.amazon.com/dp/393956611X/?tag=svpply01-20"
          "https://twitter.com/#!/tw1tt3rart"
          "http://www.youtube.com/watch?v=4-kJZGC7_9Q&feature=youtu.be&t=29s"
          "http://#{Constants.domain}/greg"
        ]

        it "should correctly identify the posting url", ->
          _.each urls, (url) ->
            _.each scenarios, (s) ->
              Page::parse_url(s+url).should.equal(url)

        it "should correctly add protocol to the url if needed", ->
          trim_protocol = /^(?:https?:\/\/)(.*)/

          _.each urls, (url) ->
            url = trim_protocol.exec(url)[1]
            _.each scenarios, (s) ->
              Page::parse_url(s+url).should.equal("http://#{url}")
