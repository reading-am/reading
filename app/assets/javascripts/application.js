window.reading || (window.reading = {});
var require = curl;

require({
  apiContext: window.reading,
  defineContext: window.reading,
  baseUrl: "//0.0.0.0:3000/assets",
  packages: {
    app: {
      path: "backbone",
      main: "reading"
    },
    extend: {
      path: "libs/extend"
    },
    plugins: {
      path: "jquery"
    }
  },
  paths: {
    jquery: "libs/jquery",
    jquery_ui: "libs/jquery_ui",
    underscore: "libs/lodash_extended",
    backbone: "libs/backbone_extended",
    handlebars: "libs/handlebars_extended"
  }
});

/*
 MIT License (c) copyright B Cavalier & J Hann */

var s=!0,B=!1;
(function(u){function O(){}function y(a,c){return 0==C.call(a).indexOf("[object "+c)}function z(a){return a&&"/"==a.charAt(a.length-1)?a.substr(0,a.length-1):a}function H(a,c){var b,j,e;j=1;a=a.replace(k,function(a,c,b,p){b&&j++;e=s;return p||""});return e?(b=c.split("/"),b.splice(b.length-j,j),b.concat(a||[]).join("/")):a}function I(a){var c=a.indexOf("!");return{J:a.substr(c+1),k:0<=c&&a.substr(0,c)}}function J(){}function K(a){J.prototype=a;a=new J;J.prototype=o;return a}function w(){function a(a,c,
b){j.push([a,c,b])}function c(a,c){for(var b,e=0;b=j[e++];)(b=b[a])&&b(c)}var b,j,e;b=this;j=[];e=function(b,p){a=b?function(a){a&&a(p)}:function(a,c){c&&c(p)};e=O;c(b?0:1,p);c=O;j=i};this.Z=function(c,b,e){a(c,b,e)};this.h=function(a){b.ga=a;e(s,a)};this.c=function(a){b.fa=a;e(B,a)};this.p=function(a){c(2,a)}}function q(a,c,b,j){a instanceof w?a.Z(c,b,j):c(a)}function x(a,c,b){var j;return function(){0<=--a&&c&&(j=c.apply(i,arguments));0==a&&b&&b(j);return j}}function D(){function a(c,b,e){var d;
d=h.f(m,i,[].concat(c));this.then=c=function(a,c){q(d,function(c){a&&a.apply(i,c)},function(a){if(c)c(a);else throw a;});return this};this.next=function(c,b){return new a(c,b,d)};b&&c(b);q(e,function(){h.j(d)})}var c=[].slice.call(arguments);y(c[0],"Object")&&(m=h.C(c.shift()),h.t(m));return new a(c[0],c[1])}function L(a){var c=a.id;if(c==i)if(d!==i)d={A:"Multiple anonymous defines in url"};else if(!(c=h.U()))d=a;if(c!=i){var b=n[c];c in n||(b=h.l(c,m).e,b=n[c]=h.v(b,c));b instanceof w&&(b.aa=B,h.w(b,
a))}}var m=u.reading.curl,E=u.document,F=E&&(E.head||E.getElementsByTagName("head")[0]),M={},N={},P={},G={},o={},C=o.toString,i,A={loaded:1,interactive:P,complete:1},n={},b=B,d,f=/\?/,g=/^\/|^[^:]+:\/\//,k=/(\.)(\.?)(?:$|\/([^\.\/]+.*)?)/g,T=/\/\*[\s\S]*?\*\/|(?:[^\\])\/\/.*?[\n\r]/g,U=/require\s*\(\s*["']([^"']+)["']\s*\)|(?:[^\\]?)(["'])/g,Q,h;h={f:function(a,c,b,j){function e(a){return H(a,l.d)}function d(c,b){var p,f,v,g;p=b&&function(a){b.apply(i,a)};if(y(c,"String")){f=e(c);v=n[f];g=v instanceof w&&
v.a;if(!(f in n))throw Error("Module not resolved: "+f);if(p)throw Error("require(id, callback) not allowed");return g||v}q(h.j(h.f(a,l.d,c,j)),p)}var l;l=new w;l.d=l.id=c||"";l.V=j;l.z=b;l.q=d;d.toUrl=function(c){return h.l(e(c),a).url};l.$=e;return l},v:function(a,c,d,j){var e,f,l;e=h.f(a,c,i,d);e.d=j==i?c:j;f=e.h;l=x(1,function(a){e.n=a;try{return h.N(e)}catch(c){e.c(c)}});e.h=function(a){q(d||b,function(){f(n[e.id]=l(a))})};e.B=function(a){q(d||b,function(){e.a&&(l(a),e.p(N))})};return e},L:function(a,
c,b,j){a=h.f(a,c,i,b);a.d=j;return a},T:function(a){return a.q},D:function(a){return a.a||(a.a={})},S:function(a){var c=a.o;c||(c=a.o={id:a.id,uri:h.F(a),exports:h.D(a)},c.a=c.exports);return c},F:function(a){return a.url||(a.url=h.u(a.q.toUrl(a.id)))},C:function(a){function c(c,b){var e,d,f,p,v;for(v in c){f=c[v];f.name=f.id||f.name||v;p=a;d=I(z(f.name||v));e=d.J;if(d=d.k)p=j[d],p||(p=j[d]=K(a),p.g=K(a.g),p.b=[]),delete c[v];if(b){d=f;var g=void 0;d.path=z(d.path||d.location||"");g=z(d.main)||"main";
"."!=g.charAt(0)&&(g="./"+g);d.G=H(g,d.name+"/");d.X=H(g,d.path+"/");d.e=d.config}else d={path:z(f)};d.K=e.split("/").length;e?(p.g[e]=d,p.b.push(e)):p.s=h.I(f,a)}}function b(a){var c=a.g;a.Y=RegExp("^("+a.b.sort(function(a,b){return c[a].K<c[b].K}).join("|").replace(/\/|\./g,"\\$&")+")(?=\\/|$)");delete a.b}var j;a.s=a.baseUrl||"";a.H="pluginPath"in a?a.pluginPath:"curl/plugin";a.g={};j=a.plugins=a.plugins||{};a.b=[];c(a.paths,B);c(a.packages,s);for(var e in j){var d=j[e].b;d&&(j[e].b=d.concat(a.b),
b(j[e]))}b(a);return a},t:function(a){var c;(c=a.preloads)&&0<c.length&&q(b,function(){b=h.j(h.f(a,i,c,s))})},l:function(a,c,b){var d,e,f,l;d=c.g;b&&(c.H&&0>a.indexOf("/")&&!(a in d))&&(f=a=z(c.H)+"/"+a);b=g.test(a)?a:a.replace(c.Y,function(c){e=d[c]||{};l=e.e;return e.G&&c==a?(f=e.G,e.X):e.path||""});return{d:f||a,e:l||m,url:h.I(b,c)}},I:function(a,c){var b=c.s;return b&&!g.test(a)?z(b)+"/"+a:a},u:function(a){return a+(f.test(a)?"":".js")},W:function(a,c,b){var d=E.createElement("script");d.onload=
d.onreadystatechange=function(b){b=b||u.event;if("load"==b.type||A[d.readyState])delete G[a.id],d.onload=d.onreadystatechange=d.onerror="",c()};d.onerror=function(){b(Error("Syntax or http error: "+a.url))};d.type=a.da||"text/javascript";d.charset="utf-8";d.async=!a.ea;d.src=a.url;G[a.id]=d;F.insertBefore(d,F.firstChild);return d},O:function(a){var c=[],b;("string"==typeof a?a:a.toSource?a.toSource():a.toString()).replace(T,"").replace(U,function(a,d,f){f?b=b==f?i:b:b||c.push(d);return a});return c},
R:function(a){var c,b,d,e,f,g;f=a.length;d=a[f-1];e=y(d,"Function")?d.length:-1;2==f?y(a[0],"Array")?b=a[0]:c=a[0]:3==f&&(c=a[0],b=a[1]);!b&&0<e&&(g=s,b=["require","exports","module"].slice(0,e).concat(h.O(d)));return{id:c,n:b||[],r:0<=e?d:function(){return d},m:g}},N:function(a){var b;b=a.r.apply(a.m?a.a:i,a.n);b===i&&a.a&&(b=a.o?a.a=a.o.a:a.a);return b},w:function(a,b){a.r=b.r;a.m=b.m;a.z=b.n;h.j(a)},j:function(a){function b(a,c,d){l[c]=a;d&&k(a,c)}function d(b,c){var e,f,g,j;e=x(1,function(a){f(a);
o(a,c)});f=x(1,function(a){k(a,c)});g=h.P(b,a);(j=g instanceof w&&g.a)&&f(j);q(g,e,a.c,a.a&&function(a){g.a&&(a==M?f(g.a):a==N&&e(g.a))})}function f(){a.h(l)}var e,g,l,m,n,k,o;l=[];g=a.z;m=g.length;0==g.length&&f();k=x(m,b,function(){a.B&&a.B(l)});o=x(m,b,f);for(e=0;e<m;e++)n=g[e],n in Q?(o(Q[n](a),e,s),a.a&&a.p(M)):n?d(n,e):o(i,e,s);return a},Q:function(a){h.F(a);h.W(a,function(){var b=d;d=i;a.aa!==B&&(!b||b.A?a.c(Error(b&&b.A||"define() missing or duplicated: "+a.url)):h.w(a,b))},a.c);return a},
P:function(a,b){var d,f,e,g,l,k,i,o,r;d=b.$;f=b.V;e=I(a);k=e.J;g=d(e.k||k);i=h.l(g,m,!!e.k);if(e.k)l=g;else if(l=i.e.moduleLoader)k=g,g=l,i=h.l(l,m);e=n[g];g in n||(e=n[g]=h.v(i.e,g,f,i.d),e.url=h.u(i.url),h.Q(e));g==l&&(o=new w,r=m.plugins[l]||m,q(e,function(a){var b,c,e;e=a.dynamic;k="normalize"in a?a.normalize(k,d,r)||"":d(k);c=l+"!"+k;b=n[c];if(!(c in n)){b=h.L(r,c,f,k);e||(n[c]=b);var g=function(a){b.h(a);e||(n[c]=a)};g.resolve=g;g.reject=b.c;a.load(k,b.q,g,r)}o!=b&&q(b,o.h,o.c,o.p)},o.c));return o||
e},U:function(){var a;if(!y(u.opera,"Opera"))for(var b in G)if(A[G[b].readyState]==P){a=b;break}return a}};Q={require:h.T,exports:h.D,module:h.S};if(!y(m,"Function")){m=h.C(m||{});h.t(m);var r,t,R,S;r=m.apiName||"curl";R=m.defineName||"define";t=m.apiContext||u;S=m.defineContext||u;t[r]=D;S[R]=r=function(){var a=h.R(arguments);L(a)};n.curl=D;D.version="0.6.3";r.amd={plugins:s,jQuery:s,curl:"0.6.3"};n["curl/_privileged"]={core:h,cache:n,cfg:m,_define:L,_curl:D,Promise:w}}})(this);
(function(u){function O(b,d){var f=b.link;f[D]=f[L]=function(){if(!f.readyState||"complete"==f.readyState)N["event-link-onload"]=s,K(b),d()}}function y(b){for(var b=b.split("!"),d,f=1;d=b[f++];)d=d.split("=",2),b[d[0]]=2==d.length?d[1]:s;return b}function z(b){if(document.createStyleSheet&&(i||(i=document.createStyleSheet()),30<=document.styleSheets.length)){var d,f,g,k=0;g=i;i=null;for(f=document.getElementsByTagName("link");d=f[k];)d.getAttribute("_curl_movable")?(g.addImport(d.href),d.parentNode&&
d.parentNode.removeChild(d)):k++}b=b[m]("link");b.rel="stylesheet";b.type="text/css";b.setAttribute("_curl_movable",s);return b}function H(b){var d,f,g=B;try{if(d=b.sheet||b.styleSheet,(g=(f=d.cssRules||d.rules)?0<f.length:f!==F)&&"[object Chrome]"=={}.toString.call(window.ca))d.insertRule("#_cssx_load_test{margin-top:-5px;}",0),A||(A=o[m]("div"),A.id="_cssx_load_test",C.appendChild(A)),g="-5px"==o.defaultView.getComputedStyle(A,null).marginTop,d.deleteRule(0)}catch(k){g=1E3==k.code||k.message.match(/security|denied/i)}return g}
function I(b,d){H(b.link)?(K(b),d()):E||setTimeout(function(){I(b,d)},b.ba)}function J(b,d){function f(){g||(g=s,d())}var g;O(b,f);N["event-link-onload"]||I(b,f)}function K(b){b=b.link;b[D]=b[L]=null}function w(b,d){return b.replace(G,function(b,g){var k=g;P.test(k)||(k=d+k);return'url("'+k+'")'})}function q(b){clearTimeout(q.M);q.i?q.i.push(b):(q.i=[b],n=o.createStyleSheet?o.createStyleSheet():C.appendChild(o.createElement("style")));q.M=setTimeout(function(){var b,f;b=n;n=F;f=q.i.join("\n");q.i=
F;f=f.replace(/.+charset[^;]+;/g,"");"cssText"in b?b.cssText=f:b.appendChild(o.createTextNode(f))},0);return n}function x(b){return{cssRules:function(){return b.cssRules||b.rules},insertRule:b.insertRule||function(d,f){var g=d.split(/\{|\}/g);b.addRule(g[0],g[1],f);return f},deleteRule:b.deleteRule||function(d){b.removeRule(d);return d},sheet:function(){return b}}}var D="onreadystatechange",L="onload",m="createElement",E=B,F,M={},N={},P=/^\/|^[^:]*:\/\//,G=/url\s*\(['"]?([^'"\)]*)['"]?\)/g,o=u.document,
C;o&&(C=o.head||(o.head=o.getElementsByTagName("head")[0]));var i,A,n;reading.define("css",{normalize:function(b,d){var f,g;if(!b)return b;f=b.split(",");g=[];for(var k=0,i=f.length;k<i;k++)g.push(d(f[k]));return g.join(",")},load:function(b,d,f,g){function k(){--n==0&&setTimeout(function(){f(x(t.sheet||t.styleSheet))},0)}var i=(b||"").split(","),n=i.length;if(b)for(var m=i.length-1,h;m>=0;m--,h=s){var b=i[m],b=y(b),r=b.shift(),r=d.toUrl(r.lastIndexOf(".")<=r.lastIndexOf("/")?r+".css":r),t=z(o),u={link:t,
url:r,ba:g.cssWatchPeriod||50};("nowait"in b?b.nowait!="false":g.cssDeferLoad)?f(x(t.sheet||t.styleSheet)):J(u,k);t.href=r;h?C.insertBefore(t,M[h].previousSibling):C.appendChild(t);M[r]=t}else f({translateUrls:function(b,a){var c;c=d.toUrl(a);c=c.substr(0,c.lastIndexOf("/")+1);return w(b,c)},injectStyle:function(b){return q(b)},proxySheet:function(b){if(b.sheet)b=b.sheet;return x(b)}})},"plugin-builder":"./builder/css"})})(this);

require(["jquery", "libs/base58", "libs/indian", "app", "app/models/post", "models/current_user", "plugins/rails", "plugins/cookies", "components/titlecard", "views/settings", "views/post", "views/user", "views/hooks/init"], function($, base58, Indian, App, Post, current_user) {
  var current_time;
  window.current_user = current_user;
  if (!$.cookie("timezone")) {
    current_time = new Date();
    $.cookie("timezone", current_time.getTimezoneOffset(), {
      path: "/",
      expires: 10
    });
  }
  window.hasfocus = true;
  $(window).focus(function() {
    return window.hasfocus = true;
  }).blur(function() {
    return window.hasfocus = false;
  });
  $(function() {
    var $search, do_provider_method, framed;
    framed = window.top !== window;
    if (framed) {
      $("body").addClass("framed");
    }
    $("a.external").on("click", function() {
      var $this, base58_id, document_host, link_host, post, pre;
      $this = $(this);
      link_host = this.href.split("/")[2];
      document_host = document.location.href.split("/")[2];
      base58_id = (typeof $this.data("base58-id") !== "undefined" ? $this.data("base58-id") : "");
      if (link_host !== document_host) {
        if (framed) {
          pre = ("//" + document_host + "/") + (base58_id ? "p/" + base58_id + "/" : "");
          window.top.location = pre + this.href;
        } else {
          if (current_user.logged_in()) {
            post = new Post({
              url: this.href,
              referrer_id: (base58_id ? base58.decode(base58_id) : "")
            });
            post.save();
          }
          window.open(this.href);
        }
        return false;
      }
    });
    $(".footnote").on("click", function() {
      window.open($(this).data("url"), "footnote", "location=0,status=0,scrollbars=0,width=900,height=400");
      return false;
    });
    $search = $("#search input");
    if ($search.val()) {
      $search.focus();
    }
    do_provider_method = function(provider, method) {
      var auth, uid,
        _this = this;
      uid = method === "connect" ? "new" : null;
      auth = new App.Models["" + provider + "Auth"](uid);
      $('#loading').fadeIn();
      auth.login({
        success: function(response) {
          return window.location.reload(true);
        },
        error: function(response) {
          var _ref;
          $('#loading').hide();
          return alert(((_ref = Constants.errors[response.status]) != null ? _ref : Constants.errors.generic).replace(/{provider}/gi, provider));
        }
      });
      return false;
    };
    $("a[data-provider][data-method]").on("click", function() {
      var $this;
      $this = $(this);
      return do_provider_method($this.data("provider"), $this.data("method"));
    });
    $("#authorizations select").on("change", function() {
      var $this;
      $this = $(this);
      do_provider_method($this.val(), $this.data("method"));
      return $this.val($this.find('option:first').val());
    });
    $(".chrome-install").on("click", function() {
      if (/chrome/.test(navigator.userAgent.toLowerCase())) {
        chrome.webstore.install();
        return false;
      }
    });
    return $(".firefox-install").on("click", function() {
      window.open($(this).attr("href"));
      return false;
    });
  });
  if (Indian.is) {
    window.document.title = 'âœŒ Reading';
    return $(window).focus(function() {
      Indian.badge("");
      return $(".post.new").fadeTo("medium", 1).removeClass("new");
    });
  }
});
