require "spec_helper"

ShimCurl = Struct.new 'ShimCurl', :last_effective_url, :body_str

describe Page do
  fixtures :pages

  context "when saved" do

    before do
      @curl = ShimCurl.new 'http://www.youtube.com/watch?v=sIy4KsWq-FA&feature=youtu.be&t=1m36s','
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta name="description" content="Slint plays &quot;Nosferatu Man&quot; on February 22 2005 at the Brown Theatre in Louisville, Kentucky.">
          <meta name="keywords" content="slint, louisville, indie, punk, rock, hardcore, kentucky, reunion, pajo, walford, nosferatu">
          <link rel="alternate" type="application/json+oembed" href="http://www.youtube.com/oembed?format=json&amp;url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DsIy4KsWq-FA" title="Slint - &quot;Nosferatu Man&quot;">
          <link rel="alternate" type="text/xml+oembed" href="http://www.youtube.com/oembed?format=xml&amp;url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DsIy4KsWq-FA" title="Slint - &quot;Nosferatu Man&quot;">
          <meta property="og:url" content="http://www.youtube.com/watch?v=sIy4KsWq-FA">
          <meta property="og:title" content="Slint - &quot;Nosferatu Man&quot;">
          <meta property="og:description" content="Slint plays &quot;Nosferatu Man&quot; on February 22 2005 at the Brown Theatre in Louisville, Kentucky.">
          <meta property="og:type" content="video">
          <meta property="og:image" content="http://i4.ytimg.com/vi/sIy4KsWq-FA/mqdefault.jpg">
          <meta property="og:video" content="http://www.youtube.com/v/sIy4KsWq-FA?version=3&amp;autohide=1">
          <meta property="og:video:type" content="application/x-shockwave-flash">
          <meta property="og:video:width" content="480">
          <meta property="og:video:height" content="360">
          <meta property="og:site_name" content="YouTube">
          <meta property="fb:app_id" content="87741124305">
          <meta name="twitter:card" value="player">
          <meta name="twitter:site" value="@youtube">
          <meta name="twitter:player" value="https://www.youtube.com/embed/sIy4KsWq-FA">
          <meta property="twitter:player:width" content="480">
          <meta property="twitter:player:height" content="360">
          <link id="css-4203806628" rel="stylesheet" href="http://s.ytimg.com/yts/cssbin/www-core-vfl-cgC9_.css">
        </head>
        <body>
        </body>
        </html>'
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
