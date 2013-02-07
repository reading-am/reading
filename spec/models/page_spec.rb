require "spec_helper"

ShimCurl = Struct.new 'ShimCurl', :last_effective_url

describe Page do
  fixtures :pages

  context "when saved" do

    before do
      @curl = ShimCurl.new 'http://www.youtube.com/watch?v=sIy4KsWq-FA&feature=youtu.be&t=1m36s'
    end

    it "resolves the canonical url" do
      page = pages(:youtube_short)
      page.curl = @curl
      page.remote_canonical.should eq("http://www.youtube.com/watch?v=sIy4KsWq-FA")
    end

    it "accurately parses the meta tags" do
      page = pages(:youtube_short)
      page.curl = @curl
      page.remote_meta_tags.should eq(page.meta_tags)
    end

  end
end
