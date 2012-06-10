#= require curl_config
#= require libs/curl

reading.curl [
  "underscore"
  "app/models/uris/amazon_product"
], (_, AmazonProduct) ->

  urls = [
    "http://www.amazon.com/dp/393956611X/"
    "http://www.amazon.com/gp/product/093087837X/ref=s9_simh_gw_p14_d0_g14_i6?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=13R6PHX83JVBWVD44VVA&pf_rd_t=101&pf_rd_p=470938631&pf_rd_i=507846&tag=reading048-20"
    "http://www.amazon.fr/Reef-Thermo-Ahi-Tongs-homme/dp/B007D0CIFK/ref=sr_1_1?m=A1X6FK5RDHNB96&s=shoes&ie=UTF8&qid=1339202164&sr=1-1&tag=reading048-20"
    "http://www.amazon.co.jp/Eye-Ai-Japan-August-2012-%E5%8D%98%E5%8F%B7/dp/B0084VR9LU/ref=sr_1_1?s=english-books&ie=UTF8&qid=1339202081&sr=1-1"
  ]

  describe "AmazonProduct", ->

    describe "#regex", ->
      it "should successfully identify urls", ->
        _.each urls, (url) ->
          AmazonProduct::regex.test(url).should.be.true

    describe "#initialize()", ->
      it "should return the correct id after initialization", ->
        model = new AmazonProduct string: urls[0]
        model.get("id").should.equal("393956611X")

      it "should return the correct image after initialization", ->
        model = new AmazonProduct string: urls[0]
        model.get("image").should.equal("http://ec2.images-amazon.com/images/P/393956611X.01._SCMZZZZZZZ_.jpg")
