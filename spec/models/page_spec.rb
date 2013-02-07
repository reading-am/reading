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
          <title>Slint - "Nosferatu Man" - YouTube</title>
          <meta name="title" content=\'Slint - "Nosferatu Man"\'>
          <meta name="description" content=\'Slint plays "Nosferatu Man" on February 22 2005 at the Brown Theatre in Louisville, Kentucky.\'>
          <meta name="keywords" content="slint, louisville, indie, punk, rock, hardcore, kentucky, reunion, pajo, walford, nosferatu">
          <meta property="og:url" content="http://www.youtube.com/watch?v=sIy4KsWq-FA">
          <meta property="og:title" content=\'Slint - "Nosferatu Man"\'>
          <meta property="og:description" content=\'Slint plays "Nosferatu Man" on February 22 2005 at the Brown Theatre in Louisville, Kentucky.\'>
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
          <meta itemprop="name" content=\'Slint - "Nosferatu Man"\'>
          <meta itemprop="description" content=\'Slint plays "Nosferatu Man" on February 22 2005 at the Brown Theatre in Louisville, Kentucky.\'>
          <meta itemprop="duration" content="PT5M35S">
          <meta itemprop="unlisted" content="False">
          <meta itemprop="paid" content="False">
          <meta itemprop="width" content="320">
          <meta itemprop="height" content="180"><meta itemprop="playerType" content="Flash">
          <meta itemprop="width" content="480">
          <meta itemprop="height" content="360">
          <meta itemprop="isFamilyFriendly" content="True">
          <meta itemprop="regionsAllowed" content="AD,AE,AF,AG,AI,AL,AM,AO,AQ,AR,AS,AT,AU,AW,AX,AZ,BA,BB,BD,BE,BF,BG,BH,BI,BJ,BL,BM,BN,BO,BQ,BR,BS,BT,BV,BW,BY,BZ,CA,CC,CD,CF,CG,CH,CI,CK,CL,CM,CN,CO,CR,CU,CV,CW,CX,CY,CZ,DE,DJ,DK,DM,DO,DZ,EC,EE,EG,EH,ER,ES,ET,FI,FJ,FK,FM,FO,FR,GA,GB,GD,GE,GF,GG,GH,GI,GL,GM,GN,GP,GQ,GR,GS,GT,GU,GW,GY,HK,HM,HN,HR,HT,HU,ID,IE,IL,IM,IN,IO,IQ,IR,IS,IT,JE,JM,JO,JP,KE,KG,KH,KI,KM,KN,KP,KR,KW,KY,KZ,LA,LB,LC,LI,LK,LR,LS,LT,LU,LV,LY,MA,MC,MD,ME,MF,MG,MH,MK,ML,MM,MN,MO,MP,MQ,MR,MS,MT,MU,MV,MW,MX,MY,MZ,NA,NC,NE,NF,NG,NI,NL,NO,NP,NR,NU,NZ,OM,PA,PE,PF,PG,PH,PK,PL,PM,PN,PR,PS,PT,PW,PY,QA,RE,RO,RS,RU,RW,SA,SB,SC,SD,SE,SG,SH,SI,SJ,SK,SL,SM,SN,SO,SR,SS,ST,SV,SX,SY,SZ,TC,TD,TF,TG,TH,TJ,TK,TL,TM,TN,TO,TR,TT,TV,TW,TZ,UA,UG,UM,US,UY,UZ,VA,VC,VE,VG,VI,VN,VU,WF,WS,YE,YT,ZA,ZM,ZW">
          <link rel="search" type="application/opensearchdescription+xml" href="http://www.youtube.com/opensearch?locale=en_US" title="YouTube Video Search">
          <link rel="shortcut icon" href="http://s.ytimg.com/yts/img/favicon-vfldLzJxy.ico" type="image/x-icon">
          <link rel="icon" href="//s.ytimg.com/yts/img/favicon_32-vflWoMFGx.png" sizes="32x32">
          <link rel="canonical" href="/watch?v=sIy4KsWq-FA">
          <link rel="alternate" media="handheld" href="http://m.youtube.com/watch?v=sIy4KsWq-FA">
          <link rel="alternate" media="only screen and (max-width: 640px)" href="http://m.youtube.com/watch?v=sIy4KsWq-FA">
          <link rel="shortlink" href="http://youtu.be/sIy4KsWq-FA">
          <link rel="alternate" type="application/json+oembed" href="http://www.youtube.com/oembed?format=json&amp;url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DsIy4KsWq-FA" title=\'Slint - "Nosferatu Man"\'>
          <link rel="alternate" type="text/xml+oembed" href="http://www.youtube.com/oembed?format=xml&amp;url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DsIy4KsWq-FA" title=\'Slint - "Nosferatu Man"\'>
          <link itemprop="url" href="http://www.youtube.com/watch?v=sIy4KsWq-FA">
          <link itemprop="url" href="http://www.youtube.com/user/olderthanyou"><link itemprop="thumbnailUrl" href="http://i4.ytimg.com/vi/sIy4KsWq-FA/hqdefault.jpg">
          <link itemprop="url" href="http://i4.ytimg.com/vi/sIy4KsWq-FA/mqdefault.jpg">
          <link itemprop="embedURL" href="http://www.youtube.com/v/sIy4KsWq-FA?version=3&amp;autohide=1">
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
