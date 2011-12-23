(function($, params){
if(typeof params.referrer_id == 'undefined') params.referrer_id = 0;

var host        = window.location.host,
    // domain = '0.0.0.0:3000', // for dev
    domain      = host.indexOf('0.0.0.0') == 0 ? '0.0.0.0:3000' : host.indexOf('staging.reading.am') == 0 ? 'staging.reading.am' : 'reading.am',
    on_reading  = (host.indexOf('reading.am') == 0 || host.indexOf('staging.reading.am') == 0 || host.indexOf('0.0.0.0') == 0),
    pass_thru   = (params.token == '-' || (on_reading && !params.token)), //don't post anything, just forward on
    has_token   = false,
    readers     = false;

var parse_url = function(){
  var url = window.location.href.split(window.location.host)[1].substring(1);
  // remove token and post id from url
  while(on_reading && (url.substring(0,2) == 't/' || url.substring(0,2) == 'p/')){
    if(url.substring(0,2) == 't/') has_token = true;
    url = url.substring(url.indexOf('/',2)+1);
  }
  if(url.indexOf('://') == -1) url = 'http://'+url;
  return url;
};

var url   = on_reading ? parse_url() : window.location.href,
    title = on_reading ? '' : window.document.title;

if(pass_thru) return window.location = url;

var show_overlay = function(){
  var $css = $('<style type="text/css">'+
        '#r_am, #r_am * {'+
          'padding:0;'+
          'margin:0;'+
          'color:#000;'+
          'background:none;'+
          'border:none;'+
          'font-family:"Helvetica Neue", helvetica, arial, sans-serif;'+
          'font-weight:normal;'+
          'font-style:normal;'+
          'font-size:12px;'+
          'line-height:normal;'+
          'text-align:center;'+
          'text-decoration:none;'+
          'text-shadow:none;'+
          'text-transform:none;'+
          'font-variant:normal;'+
          'letter-spacing:normal;'+
          'list-style:none;'+
        '}'+
        '#r_am {'+
          'display:none;'+
          'z-index:99999999;'+
          'position:fixed;'+
          'top:15px;'+
          'right:15px;'+
        '}'+
        '#r_wrp {'+
          'overflow:hidden;'+
          'height:60px;'+
          'width:50px;'+
          'padding:10px 10px 5px;'+
        '}'+
        '#r_wrp, #r_am li {'+
          'background:yellow;'+
        '}'+
        '#r_icon {'+
          'font-size:56px;'+
          'line-height:0;'+
          'margin:18px 0 25px;'+
        '}'+
        '#r_actions {'+
          'margin:10px 0 0;'+
          'width:130px;'+
        '}'+
        '#r_am a:hover, #r_am .r_active {'+
          'background:#FFF;'+
        '}'+
        '#r_actions .r_inactive {'+
          'text-decoration:line-through;'+
        '}'+
        '#r_am ul {'+
          'margin:3px 0 0 0;'+
        '}'+
        '#r_am li {'+
          'float:right;'+
          'clear:both;'+
          'padding:3px 5px;'+
          'margin:3px 0;'+
        '}'+
        '#r_stuff_menu, #r_readers {'+
          'display:none;'+
        '}'+
        '#r_nope {'+
          'margin:0 3px 0 0;'+
        '}'+
        '#r_stuff {'+
          'margin:0 3px;'+
        '}'+
        '#r_close {'+
          'margin:0 0 0 3px;'+
        '}'+
      '</style>').appendTo('head');
      $icon = $('<div id="r_icon">&#9996;</div>'),
      $subtext = $('<div>Reading</div>'),
      $actions = $('<div id="r_actions"><a href="#" id="r_yep">Yep</a> . <a href="#" id="r_nope">Nope</a> &#8942; <a href="#" id="r_stuff">Stuff</a> &#8942; <a href="#" id="r_close">&#10005;</a></div>'),
      $wrapper = $('<div id="r_wrp">').append($icon).append($subtext).append($actions),
      $reading = $('<div id="r_am">').append($wrapper).append($stuff);
  if(readers){
    var $readers = $('<ul id="r_readers">').append('<li>&#8258; Other Readers</li>');
    $.each(readers, function(i, user){
      $readers.append('<li><a href="http://'+domain+'/'+user.username+'">'+user.display_name+'</a></li>');
    });
    $reading.append($readers);
  }
  $('body').prepend($reading);
  $reading.fadeIn(500, function(){
    $wrapper.delay(1000).animate({height:'14px', width:$actions.width()});
    $icon.delay(1000).animate({'margin-top':'-52px'});
    if(readers) $readers.delay(1200).slideDown();
  });
  $('#r_close').click(function(){
    $reading.fadeOut(400, function(){ $reading.remove(); });
    return false;
  });
  $('#r_yep, #r_nope').click(function(){
    var $this = $(this),
        $close= $('#r_close'),
        i = 0,
        shapes = ['&#10043;','&#10044;','&#10045;','&#10046;'],
        loading = setInterval(function(){
          $close.html(shapes[i]);
          i = i < shapes.length-1 ? i+1 : 0;
        }, 250);
    params.post.yn = $this.is('#r_yep');
    $other = params.post.yn ? $('#r_nope') : $('#r_yep');
    $other
      .removeClass('r_active')
      .addClass('r_inactive');
    $this
      .removeClass('r_inactive')
      .addClass('r_active');
    post_update(params, function(){
      clearInterval(loading);
      $close.html('&#10005;');
    });
    return false;
  });

  // STUFF!
  var $stuff = $('<ul id="r_stuff_menu">'),
      providers = [
        {
          name: 'Twitter',
          url: 'https://twitter.com/share?url={shorturl}&text=✌%20Reading%20%22{title}%22',
          action: function(url){ popup(url, 475, 345); }
        },
        {
          name: 'Facebook',
          url: 'https://www.facebook.com/sharer.php?u={shorturl}&t={title}',
          action: function(url){ popup(url, 520, 370); }
        },
        {
          name: 'Instapaper',
          url: 'http://www.instapaper.com/hello2?url={url}&title={title}',
          action: function(url){ window.location = url; }
        },
        {
          name: 'Readability',
          url: 'http://www.readability.com/save?url={url}',
          action: function(url){ window.location = url; }
        },
        {
          name: 'Read It Later',
          url: 'https://readitlaterlist.com/save?url={url}&title={title}',
          action: function(url){ popup(url, 490, 400); }
        }
      ],
  popup = function(url, width, height){
    window.open(url, 'r_win', 'location=0,toolbars=0,status=0,directories=0,menubar=0,resizable=0,width='+width+',height='+height);
  },
  share_url = function(provider, post){
    var params = {
      url:      window.location.href,
      shorturl: 'http://'+post.short_url,
      title:    document.title
    },
    url = provider.url;
    for(param in params) url = url.replace('{'+param+'}', encodeURIComponent(params[param]));
    return url;
  },
  show_stuff = function(){
    $stuff.show();
    if(readers) $readers.hide();
    $('#r_stuff').addClass('r_active');
  }
  hide_stuff = function(){
    $stuff.hide();
    if(readers) $readers.show();
    $('#r_stuff').removeClass('r_active');
  };
  for(var i = 0; i < providers.length; i++){
    $stuff.append('<li><a href="#" class="r_share" data-provider_id="'+i+'">'+providers[i].name+'</a></li>');
  }
  $reading.append($stuff);
  $('#r_stuff')
    .mouseenter(function(){ show_stuff(); })
    .click(function(){ return false; });
  $reading.mouseleave(function(){ hide_stuff(); });
  $('a:not(#r_stuff)', $actions).mouseenter(function(){ hide_stuff(); });
  $('.r_share', $reading).click(function(){
    var prov = providers[$(this).attr('data-provider_id')];
    prov.action(share_url(prov, params.post));
  });
  $(window).scroll(function(){
    if($actions.find('.r_active').length){
      $('#r_close').click();
    }
  });

};

var params = {token: params.token, referrer_id: params.referrer_id, url: url};
if(!on_reading) params.title = window.document.title;

var post_create = function(data, success){
  $.ajax({
    url: 'http://'+domain+'/posts/create.json',
    dataType: 'jsonp',
    data: data,
    success: function(data, textStatus, jqXHR){
      if(data.meta.status == 400){
        alert('Sorry, an error prevented this page from being posted to Reading');
      } else if(success) {
        success(data.response);
      }
    }
  });
},
post_update = function(data, success){
  $.ajax({
    url: 'http://'+domain+'/posts/'+data.post.id+'/update.json',
    dataType: 'jsonp',
    data: data,
    success: function(data, textStatus, jqXHR){
      if(data.meta.status != 400 && success){
        success(data.response);
      }
    }
  });
};

// submit the inital post on script load
post_create(params, function(data){
  if(on_reading){
    if(has_token){
      // forward back through to Reading so that the user's
      // token doesn't show up in the referrer
      window.location = 'http://'+domain+'/t/-/'+url;
    } else {
      window.location = url;
    }
  } else {
    params.post = data.post;
    readers = (data.readers.length ? data.readers : false);
    show_overlay();
    var updating = false;
    // update the date_created every 15 seconds ala chartbeat
    setInterval(function(){
      if(!updating){
        updating = true;
        post_update(params, function(){ updating = false; });
      }
    }, 15000);
  }
});

})(jQuery, reading);
