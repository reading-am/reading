require "rails_helper"

describe Page do
  fixtures :pages

  context "when cleaning up the url" do

    it "restores missing slashes in the protocol" do
      expect(Page.cleanup_url("http:/testing.com/http:/here")).to eq("http://testing.com/http:/here")
      expect(Page.cleanup_url("https:/testing.com/http:/here")).to eq("https://testing.com/http:/here")
      expect(Page.cleanup_url("https://testing.com")).to eq("https://testing.com/")
    end

    it "adds a protocol when one is missing" do
      expect(Page.cleanup_url("testing.com/here/is")).to eq("http://testing.com/here/is")
    end

    it "lowercases the scheme/protocol and host" do
      expect(Page.cleanup_url("HTTPs://teSTing.com/HERE/is")).to eq("https://testing.com/HERE/is")
    end

  end

  context "when saved" do

    it "rejects non-web / http urls" do
      [
        "file:///Users/apple/Desktop/Site%20Practice/index.html",
        "javascript:reading={};(function(){reading.token='***REMOVED***';var otherlib=(typeof jQuery=='undefined'&&typeof $=='function');function getScript(url,success){var script=document.createElement('script');script.src=url;var head=document.getElementsByTagName('head')[0],done=false;script.onload=script.onreadystatechange=function(){if(!done&&(!this.readyState||this.readyState=='loaded'||this.readyState=='complete')){done=true;success();script.onload=script.onreadystatechange=null;head.removeChild(script);}};head.appendChild(script);}getScript('http://code.jquery.com/jquery-latest.min.js',function(){if(typeof jQuery=='undefined'){alert('There was an error loading Reading');}else{jQuery.getScript('http://www.reading.am/javascripts/reading.js');}});})();",
        # "mailto:alasdair.monk+hello@gmail.com", # Describe currently fails on this
        "chrome://newtab/",
        "http:///javascripts/application.js?1312820486",
        "about:swappedout",
        "feed://feeds.feedburner.com/mediaredef",
        "chrome-extension://mfgdmpfihlmdekaclngibpjhdebndhdj/newtab.html",
        "chrome-devtools://devtools/devtools.html?docked=true&toolbarColor=rgba(230,230,230,1)&textColor=rgba(0,0,0,1)",
        "nvalt://make/?txt=http%3A%2F%2Fcarl.flax.ie%2Fdothingstellpeople.html",
        "yorufukurou://pasteurl/'The%20Fifth%20Floor'%20(El%20Quinto%20Piso)%3A%20Who%20Will%20Rebuild%20the%20House%20of%20Puerto%20Rico%3F%20-%20Forbes%20http%3A%2F%2Fwww.forbes.com%2Fsites%2Fgiovannirodriguez%2F2013%2F01%2F16%2Fthe-fifth-floor-el-quinto-piso-who-will-rebuild-the-house-of-puerto-rico%2F"
      ].each do |url|
        # Don't hit Describe
        Page.skip_callback(:validation, :before, :populate_describe_data, raise: false)
        page = Page.new url: url
        page.save
        expect(page.new_record?).to be true
        expect(page.errors.messages).to have_key(:domain)
      end
    end
  end
end

