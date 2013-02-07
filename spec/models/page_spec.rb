require "spec_helper"

ShimCurl = Struct.new 'ShimCurl', :last_effective_url, :body_str

describe Page do
  fixtures :pages

  context "when saved" do

    before do
    end

    it "resolves the canonical url" do
      page = pages(:youtube_short)
      page.curl = ShimCurl.new 'http://www.youtube.com/watch?v=sIy4KsWq-FA&feature=youtu.be&t=1m36s', page.head_tags.to_s
      page.remote_canonical_url.should eq("http://www.youtube.com/watch?v=sIy4KsWq-FA")
    end

    it "accurately parses the title tag" do
      page = pages(:youtube_short)
      page.title_tag.should eq("Slint - \"Nosferatu Man\" - YouTube")
    end

    it "accurately parses the meta tags" do
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

    it "accurately parses the link tags" do
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

