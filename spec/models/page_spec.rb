require "spec_helper"

ShimMech = Struct.new 'ShimMech', :uri, :body_str do
  def search *args
    Nokogiri::HTML(body_str).search(*args)
  end
end

describe Page do
  fixtures :pages

  context "when cleaning up the url" do

    it "restores missing slashes in the protocol" do
      Page.cleanup_url("http:/testing.com/http:/here").should eq("http://testing.com/http:/here")
      Page.cleanup_url("https:/testing.com/http:/here").should eq("https://testing.com/http:/here")
      Page.cleanup_url("https://testing.com").should eq("https://testing.com")
    end

    it "adds a protocol when one is missing" do
      Page.cleanup_url("testing.com/here/is").should eq("http://testing.com/here/is")
    end

    it "lowercases the scheme/protocol and host" do
      Page.cleanup_url("HTTPs://teSTing.com/HERE/is").should eq("https://testing.com/HERE/is")
    end

  end

  context "when saved" do

    it "rejects non-web / http urls" do
      [
        "file:///Users/apple/Desktop/Site%20Practice/index.html",
        "javascript:reading={};(function(){reading.token='0dRF3d-er_31llmGUT-AKA';var otherlib=(typeof jQuery=='undefined'&&typeof $=='function');function getScript(url,success){var script=document.createElement('script');script.src=url;var head=document.getElementsByTagName('head')[0],done=false;script.onload=script.onreadystatechange=function(){if(!done&&(!this.readyState||this.readyState=='loaded'||this.readyState=='complete')){done=true;success();script.onload=script.onreadystatechange=null;head.removeChild(script);}};head.appendChild(script);}getScript('http://code.jquery.com/jquery-latest.min.js',function(){if(typeof jQuery=='undefined'){alert('There was an error loading Reading');}else{jQuery.getScript('http://reading.am/javascripts/reading.js');}});})();",
        "mailto:alasdair.monk+hello@gmail.com",
        "chrome://newtab/",
        "http:///javascripts/application.js?1312820486",
        "about:swappedout",
        "feed://feeds.feedburner.com/mediaredef",
        "chrome-extension://mfgdmpfihlmdekaclngibpjhdebndhdj/newtab.html",
        "chrome-devtools://devtools/devtools.html?docked=true&toolbarColor=rgba(230,230,230,1)&textColor=rgba(0,0,0,1)",
        "nvalt://make/?txt=http%3A%2F%2Fcarl.flax.ie%2Fdothingstellpeople.html",
        "yorufukurou://pasteurl/'The%20Fifth%20Floor'%20(El%20Quinto%20Piso)%3A%20Who%20Will%20Rebuild%20the%20House%20of%20Puerto%20Rico%3F%20-%20Forbes%20http%3A%2F%2Fwww.forbes.com%2Fsites%2Fgiovannirodriguez%2F2013%2F01%2F16%2Fthe-fifth-floor-el-quinto-piso-who-will-rebuild-the-house-of-puerto-rico%2F"
      ].each do |url|
        page = Page.new url: url
        page.save
        page.new_record?.should be_true
        page.errors.messages[:domain].should be_true
      end
    end

    it "resolves the canonical url when present" do
      page = pages(:youtube_short)
      page.mech = ShimMech.new URI.parse('http://www.youtube.com/watch?v=sIy4KsWq-FA&feature=youtu.be&t=1m36s'), page.head_tags.to_s
      page.remote_canonical_url.should eq("http://www.youtube.com/watch?v=sIy4KsWq-FA")
    end

    it "identifies files without html wrappers" do
      Page.observers.disable :all do
        {
          "text"  => [
            "http://law2.umkc.edu/faculty/projects/ftrials/till/Reed.pdf",
            "http://a1408.g.akamai.net/5/1408/1388/2005110403/1a1a1ad948be278cff2d96046ad90768d848b41947aa1986/sample_iPod.m4v.zip"
          ],
          "image" => [
            "http://www.hawking.org.uk/uploads/8/3/0/0/8300824/254175_orig.jpg",
            "http://25.media.tumblr.com/5253cd15777fbfb3adbaf225f61405d9/tumblr_mqaycmAF1W1qczbido1_500.gif"
          ],
          "video" => [
            "https://ia600806.us.archive.org/11/items/TheOuterLimits-Tos-1x07-O.b.i.t.avi_90/TheOuterLimits-Tos-1x07-O.b.i.t.avi",
            "http://www.mediacollege.com/video-gallery/testclips/barsandtone.flv"
          ],
          "audio" => [
            "http://www.stephaniequinn.com/Music/Allegro%20from%20Duet%20in%20C%20Major.mp3",
            "http://download.wavetlan.com/SVV/Media/HTTP/AAC/iTunes/iTunes_test1_AAC-LC_v4_Stereo_VBR_128kbps_44100Hz.m4a"
          ]
        }.each do |medium, urls|
          urls.each do |url|
            page = Page.new url: url
            page.save.should be_true
            page.medium.should eq medium
          end
        end
      end
    end

    it "accurately parses the title tag when present" do
      page = pages(:youtube_short)
      page.title_tag.should eq("Slint - \"Nosferatu Man\" - YouTube")
    end

    it "accurately parses the media type when present" do
      page = pages(:youtube_short)
      page.media_type.should eq("video")
    end

    it "accurately parses the keywords into an array when present" do
      page = pages(:youtube_short)
      page.keywords.should eq([
        'slint','louisville','indie',
        'punk','rock','hardcore',
        'kentucky','reunion','pajo',
        'walford','nosferatu'
      ])
    end

    it "accurately parses the meta tags when present" do
      page = pages(:youtube_short)
      page.meta_tags.should eq({
        "og" => {
          "url" => "http://www.youtube.com/watch?v=sIy4KsWq-FA",
          "title" => "Slint - \"Nosferatu Man\"",
          "description" => "Slint plays \"Nosferatu Man\" on February 22 2005 at the Brown Theatre in Louisville, Kentucky.",
          "type" => "video",
          "image" => "http://i4.ytimg.com/vi/sIy4KsWq-FA/mqdefault.jpg",
          "video" => "http://www.youtube.com/v/sIy4KsWq-FA?autohide=1&version=3",
          "video:type" => "application/x-shockwave-flash",
          "video:width" => "480",
          "video:height" => "360",
          "site_name" => "YouTube"
        },
        "twitter" => {
          "card" => "player",
          "site" => "@youtube",
          "player" => "https://www.youtube.com/embed/sIy4KsWq-FA",
          "player:width" => "480",
          "player:height" => "360"
        },
        "title" => "Slint - \"Nosferatu Man\"",
        "description" => "Slint plays \"Nosferatu Man\" on February 22 2005 at the Brown Theatre in Louisville, Kentucky.",
        "keywords" => "slint, louisville, indie, punk, rock, hardcore, kentucky, reunion, pajo, walford, nosferatu",
        "fb:app_id" => "87741124305",
        "name" => "Slint - \"Nosferatu Man\"",
        "duration" => "PT5M35S",
        "unlisted" => "False",
        "paid" => "False",
        "width" => "480",
        "height" => "360",
        "playerType" => "Flash",
        "isFamilyFriendly" => "True",
        "regionsAllowed" => "AD,AE,AF,AG,AI,AL,AM,AO,AQ,AR,AS,AT,AU,AW,AX,AZ,BA,BB,BD,BE,BF,BG,BH,BI,BJ,BL,BM,BN,BO,BQ,BR,BS,BT,BV,BW,BY,BZ,CA,CC,CD,CF,CG,CH,CI,CK,CL,CM,CN,CO,CR,CU,CV,CW,CX,CY,CZ,DE,DJ,DK,DM,DO,DZ,EC,EE,EG,EH,ER,ES,ET,FI,FJ,FK,FM,FO,FR,GA,GB,GD,GE,GF,GG,GH,GI,GL,GM,GN,GP,GQ,GR,GS,GT,GU,GW,GY,HK,HM,HN,HR,HT,HU,ID,IE,IL,IM,IN,IO,IQ,IR,IS,IT,JE,JM,JO,JP,KE,KG,KH,KI,KM,KN,KP,KR,KW,KY,KZ,LA,LB,LC,LI,LK,LR,LS,LT,LU,LV,LY,MA,MC,MD,ME,MF,MG,MH,MK,ML,MM,MN,MO,MP,MQ,MR,MS,MT,MU,MV,MW,MX,MY,MZ,NA,NC,NE,NF,NG,NI,NL,NO,NP,NR,NU,NZ,OM,PA,PE,PF,PG,PH,PK,PL,PM,PN,PR,PS,PT,PW,PY,QA,RE,RO,RS,RU,RW,SA,SB,SC,SD,SE,SG,SH,SI,SJ,SK,SL,SM,SN,SO,SR,SS,ST,SV,SX,SY,SZ,TC,TD,TF,TG,TH,TJ,TK,TL,TM,TN,TO,TR,TT,TV,TW,TZ,UA,UG,UM,US,UY,UZ,VA,VC,VE,VG,VI,VN,VU,WF,WS,YE,YT,ZA,ZM,ZW"
      })
    end

    it "accurately parses the link tags when present" do
      page = pages(:youtube_short)
      page.link_tags.should eq({
        "search" => "http://www.youtube.com/opensearch?locale=en_US",
        "shortcut icon" => "http://s.ytimg.com/yts/img/favicon-vfldLzJxy.ico",
        "icon" => "//s.ytimg.com/yts/img/favicon_32-vflWoMFGx.png",
        "canonical" => "/watch?v=sIy4KsWq-FA",
        "alternate" => "http://www.youtube.com/oembed?format=xml&url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DsIy4KsWq-FA",
        "shortlink" => "http://youtu.be/sIy4KsWq-FA",
        "url" => "http://i4.ytimg.com/vi/sIy4KsWq-FA/mqdefault.jpg",
        "thumbnailUrl" => "http://i4.ytimg.com/vi/sIy4KsWq-FA/hqdefault.jpg",
        "embedURL" => "http://www.youtube.com/v/sIy4KsWq-FA?autohide=1&version=3"
      })
    end

  end
end

