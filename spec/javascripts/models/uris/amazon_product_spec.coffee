define [
  "support/chai"
  "underscore"
  "jquery"
  "models/uris/shared"
  "app/models/uris/amazon_product"
], (chai, _, $, shared, AmazonProduct) ->
  chai.should()

  describe "Model", ->
    describe "URI", ->
      describe "AmazonProduct", ->

        beforeEach ->
          @id = "393956611X"
          @urls = [
            "http://www.amazon.com/dp/#{@id}/"
            "http://www.amazon.com/dp/0562001034/" # this one displays a 1px x 1px image
            "http://www.amazon.com/gp/product/093087837X/ref=s9_simh_gw_p14_d0_g14_i6?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=13R6PHX83JVBWVD44VVA&pf_rd_t=101&pf_rd_p=470938631&pf_rd_i=507846&tag=reading048-20"
            "http://www.amazon.fr/Reef-Thermo-Ahi-Tongs-homme/dp/B007D0CIFK/ref=sr_1_1?m=A1X6FK5RDHNB96&s=shoes&ie=UTF8&qid=1339202164&sr=1-1&tag=reading048-20"
            "http://www.amazon.co.jp/Eye-Ai-Japan-August-2012-%E5%8D%98%E5%8F%B7/dp/B0084VR9LU/ref=sr_1_1?s=english-books&ie=UTF8&qid=1339202081&sr=1-1"
          ]
          @model = new AmazonProduct string: @urls[0]

        shared()

        describe "#initialize()", ->
          it "should return the correct id after initialization", ->
            @model.get("id").should.equal(@id)

          it "should return the correct image after initialization", ->
            @model.get("image").should.equal("http://ec2.images-amazon.com/images/P/#{@id}.01._SCMZZZZZZZ_.jpg")

          it "should not return Amazon's dummy 1px x 1px image", (done) ->
            $img = $("<img>").hide().attr(src: @model.get("image")).load ->
              $(this).width().should.be.above(1)
              $(this).height().should.be.above(1)
              $(this).remove()
              done()

            $("body").append $img

          it "Amazon should still be returning dummy 1px x 1px images for some products", (done) ->
            @model = new AmazonProduct string: @urls[1]

            $img = $("<img>").hide().attr(src: @model.get("image")).load ->
              $(this).width().should.equal(1)
              $(this).height().should.equal(1)
              $(this).remove()
              done()

            $("body").append $img
