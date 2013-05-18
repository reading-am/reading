/*! Embedly jQuery - v3.1.0 - 2013-05-15
 * https://github.com/embedly/embedly-jquery
 * Copyright (c) 2013 Sean Creeley
 * Licensed BSD
 */ 
define(["jquery"], function(t){var e={key:null,endpoint:"oembed",secure:null,query:{},method:"replace",addImageStyles:!0,wrapElement:"div",className:"embed",batch:20,urlRe:null},i=/(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/,r=function(t){return null===t||void 0===t},n=function(e,i){var r=[],n=[];return t.each(e,function(t,e){n.push(e),n.length===i&&(r.push(n),n=[])}),0!==n.length&&r.push(n),r},s=function(e){return r(e)?[]:t.isArray(e)?e:[e]},o=function(e){return t.map(e[0],function(i,r){return[t.map(e,function(t){return t[r]})]})},a=function(t,e,i){this.init(t,e,i)};a.prototype={init:function(e){this.urls=e,this.count=0,this.results={},this._deferred=t.Deferred()},notify:function(e){if(this.results[e.original_url]=e,this.count++,this._deferred.notify.apply(this._deferred,[e]),this.count===this.urls.length){var i=this,r=t.map(this.urls,function(t){return i.results[t]});this._deferred.resolve(r)}return this},state:function(){return this._deferred.state.apply(this._deferred,arguments)}},window.Keeper=a;var l=function(){};l.prototype={defaults:{},log:function(t,e){r(window.console)||r(window.console[t])||window.console[t].apply(window.console,[e])},build:function(e,i,n){n=r(n)?{}:n;var s=n.secure;r(s)&&(s="https:"===window.location.protocol?!0:!1);var o=(s?"https":"http")+"://api.embed.ly/"+("objectify"===e?"2/":"1/")+e,a=r(n.query)?{}:n.query;return a.key=n.key,o+="?"+t.param(a),o+="&urls="+t.map(i,encodeURIComponent).join(",")},ajax:function(l,h,u){if(u=t.extend({},e,t.embedly.defaults,"object"==typeof u&&u),r(u.key))return this.log("error","Embedly jQuery requires an API Key. Please sign up for one at http://embed.ly"),null;h=s(h);var d,p=new a(h),c=[],f=[];t.each(h,function(t,e){d=!1,i.test(e)&&(d=!0,null!==u.urlRe&&u.urlRe.test&&!u.urlRe.test(e)&&(d=!1)),d===!0?c.push(e):f.push({url:e,original_url:e,error:!0,invalid:!0,type:"error",error_message:'Invalid URL "'+e+'"'})});var y=n(c,u.batch),m=this;return t.each(y,function(e,i){t.ajax({url:m.build(l,i,u),dataType:"jsonp",success:function(e){t.each(o([i,e]),function(t,e){var i=e[1];i.original_url=e[0],i.invalid=!1,p.notify(i)})}})}),f.length&&setTimeout(function(){t.each(f,function(t,e){p.notify(e)})},1),p._deferred},oembed:function(t,e){return this.ajax("oembed",t,e)},preview:function(t,e){return this.ajax("preview",t,e)},objectify:function(t,e){return this.ajax("objectify",t,e)},extract:function(t,e){return this.ajax("extract",t,e)}};var h=function(){};h.prototype={build:function(e,i,n){n=r(n)?{}:n;var s=n.secure;r(s)&&(s="https:"===window.location.protocol?!0:!1);var o=(s?"https":"http")+"://i.embed.ly/"+("display"===e?"1/":"1/display/")+e,a=r(n.query)?{}:n.query;return a.key=n.key,o+="?"+t.param(a),o+="&url="+encodeURIComponent(i)},display:function(t,e){return this.build("display",t,e)},resize:function(t,e){return this.build("resize",t,e)},fill:function(t,e){return this.build("fill",t,e)},crop:function(t,e){return this.build("crop",t,e)}};var u=function(t,e,i){this.init(t,e,i)};u.prototype={init:function(e,i,r){this.elem=e,this.$elem=t(e),this.original_url=i,this.options=r,this.loaded=t.Deferred();var n=this;this.loaded.done(function(){n.$elem.trigger("loaded",[n])}),this.$elem.trigger("initialized",[this])},progress:function(e){t.extend(this,e),this.options.display?this.options.display.apply(this.elem,[this,this.elem]):"oembed"===this.options.endpoint&&this.display(),this.loaded.resolve(this)},imageStyle:function(){var t,e=[];return this.options.addImageStyles&&(this.options.query.maxwidth&&(t=isNaN(parseInt(this.options.query.maxwidth,10))?"":"px",e.push("max-width: "+this.options.query.maxwidth+t)),this.options.query.maxheight&&(t=isNaN(parseInt(this.options.query.maxheight,10))?"":"px",e.push("max-height: "+this.options.query.maxheight+t))),e.join(";")},display:function(){if("error"===this.type)return!1;this.style=this.imageStyle();var t;"photo"===this.type?(t="<a href='"+this.original_url+"' target='_blank'>",t+="<img style='"+this.style+"' src='"+this.url+"' alt='"+this.title+"' /></a>"):"video"===this.type||"rich"===this.type?t=this.html:(this.title=this.title||this.url,t=this.thumbnail_url?"<img src='"+this.thumbnail_url+"' class='thumb' style='"+this.style+"'/>":"",t+="<a href='"+this.original_url+"'>"+this.title+"</a>",t+=this.provider_name?"<a href='"+this.provider_url+"' class='provider'>"+this.provider_name+"</a>":"",t+=this.description?'<div class="description">'+this.description+"</div>":""),this.options.wrapElement&&(t="<"+this.options.wrapElement+' class="'+this.options.className+'">'+t+"</"+this.options.wrapElement+">"),this.code=t,"replace"===this.options.method?this.$elem.replaceWith(this.code):"after"===this.options.method?this.$elem.after(this.code):"afterParent"===this.options.method?this.$elem.parent().after(this.code):"replaceParent"===this.options.method&&this.$elem.parent().replaceWith(this.code),this.$elem.trigger("displayed",[this])}},t.embedly=new l,t.embedly.display=new h,t.fn.embedly=function(i){if(void 0===i||"object"==typeof i){if(i=t.extend({},e,t.embedly.defaults,"object"==typeof i&&i),r(i.key))return t.embedly.log("error","Embedly jQuery requires an API Key. Please sign up for one at http://embed.ly"),this.each(t.noop);var n={},s=function(e){if(!t.data(t(e),"embedly")){var r=t(e).attr("href"),s=new u(e,r,i);t.data(e,"embedly",s),n.hasOwnProperty(r)?n[r].push(s):n[r]=[s]}},o=this.each(function(){r(t(this).attr("href"))?t(this).find("a").each(function(){r(t(this).attr("href"))||s(this)}):s(this)}),a=t.embedly.ajax(i.endpoint,t.map(n,function(t,e){return e}),i).progress(function(e){t.each(n[e.original_url],function(t,i){i.progress(e)})});return i.progress&&a.progress(i.progress),i.done&&a.done(i.done),o}},t.expr[":"].embedly=function(e){return!r(t(e).data("embedly"))},t.fn.display=function(i,n){if(r(i)&&(i="display"),void 0===n||"object"==typeof n){if(n=t.extend({},e,t.embedly.defaults,"object"==typeof n&&n),r(n.key))return t.embedly.log("error","Embedly jQuery requires an API Key. Please sign up for one at http://embed.ly/display"),this.each(t.noop);var s=function(e){var r=t(e);if(!r.data("display")){var s=r.data("src")||r.attr("href"),o={original_url:s,url:t.embedly.display.build(i,s,n)};r.data("display",o),r.trigger("initialized",[e]);var a="<img src='"+o.url+"' />";r.is("a")?r.append(a):r.replaceWith(a)}},o=function(e){return r(t(e).data("src"))&&r(t(e).attr("href"))?!1:!0},a=this.each(function(){o(this)?s(this):t(this).find("img,a").each(function(){o(this)&&s(this)})});return a}},t.expr[":"].display=function(e){return!r(t(e).data("display"))}});
