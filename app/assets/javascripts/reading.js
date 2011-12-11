(function($, params){
if(typeof params.referrer_id == 'undefined') params.referrer_id = 0;

var host        = window.location.host,
    domain = '0.0.0.0:3000', // for dev
    // domain      = host.indexOf('0.0.0.0') == 0 ? '0.0.0.0:3000' : host.indexOf('staging.reading.am') == 0 ? 'staging.reading.am' : 'reading.am',
    on_reading  = (host.indexOf('reading.am') == 0 || host.indexOf('staging.reading.am') == 0 || host.indexOf('0.0.0.0') == 0),
    pass_thru   = (params.token == '-' || (on_reading && !params.token)), //don't post anything, just forward on
    has_token   = false,
    post        = {},
    following   = [];

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
          'color:#000;'+
          'font-family:"Helvetica Neue", helvetica, arial, sans-serif;'+
          'font-weight:normal;'+
          'font-size:12px;'+
          'line-height:normal;'+
          'text-align:center;'+
          'text-decoration:none;'+
          'text-shadow:none;'+
          'text-transform:none;'+
          'font-variant:normal;'+
          'letter-spacing:normal;'+
          'border:none;'+
          'padding:0;'+
          'margin:0;'+
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
        '#r_am a:hover, .r_active {'+
          'background:#FFF;'+
        '}'+
        '#r_actions .r_inactive {'+
          'text-decoration:line-through;'+
        '}'+
        '#r_am ul {'+
          'margin:3px 0 0 0;'+
        '}'+
        '#r_am li {'+
          'text-align:right;'+
          'padding:3px 5px;'+
        '}'+
        '#r_am ul a {'+
          'border-right:2px solid #000;'+
          'padding:0 5px;'+
        '}'+
        '#r_stuff_menu, #r_following {'+
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
  if(following.length){
    var $following = $('<ul id="r_following">').append('<li>Other readers:</li>');
    $.each(following, function(i, username){
      $following.append('<li><a href="http://'+domain+'/'+username+'">'+username+'</a></li>');
    });
    $reading.append($following);
  }
  $('body').prepend($reading);
  $reading.fadeIn(500, function(){
    $wrapper.delay(1000).animate({height:'14px', width:$actions.width()});
    $icon.delay(1000).animate({'margin-top':'-52px'});
    $following.delay(1500).slideDown();
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
    params.yn = $this.is('#r_yep');
    $other = params.yn ? $('#r_nope') : $('#r_yep');
    $other
      .removeClass('r_active')
      .addClass('r_inactive');
    $this
      .removeClass('r_inactive')
      .addClass('r_active');
    submit_post(params, function(){
      clearInterval(loading);
      $close.html('&#10005;');
    });
    return false;
  });

  // STUFF!
  var $stuff = $('<ul id="r_stuff_menu">'),
      providers = ['twitter','facebook','instapaper','readability'],
  popup = function(url, width, height){
    window.open(url, 'r_win', 'location=0,toolbars=0,status=0,directories=0,menubar=0,resizable=0,width='+width+',height='+height);
  },
  share_url = function(provider, url, title, text){
    var url = encodeURIComponent(url),
        title = encodeURIComponent(title),
        text = '✌ '+encodeURIComponent(text);
    switch(provider.toLowerCase()){
      case 'twitter':
        return 'https://twitter.com/share?url='+url+'&text='+text;
      case 'facebook':
        return 'https://www.facebook.com/sharer.php?u='+url+'&t='+title;
      case 'instapaper':
        return 'http://www.instapaper.com/hello2?url='+encodeURIComponent(window.location.href)+'&title='+title;
      case 'readability':
        return 'http://www.readability.com/save?url='+encodeURIComponent(window.location.href);
    }
  },
  show_stuff = function(){
    $stuff.show();
    $('#r_stuff').addClass('r_active');
  }
  hide_stuff = function(){
    $stuff.hide();
    $('#r_stuff').removeClass('r_active');
  };
  for(var i = 0; i < providers.length; i++){
    $stuff.append('<li id="r_'+providers[i]+'"><a href="#" class="r_share">'+providers[i][0].toUpperCase() + providers[i].slice(1)+'</a></li>');
  }
  $reading.append($stuff);
  $('#r_stuff').mouseenter(function(){ show_stuff(); });
  $reading.mouseleave(function(){ hide_stuff(); });
  $('a:not(#r_stuff)', $actions).mouseenter(function(){ hide_stuff(); });
  $('.r_share', $reading).click(function(){
    popup(share_url($(this).text(), 'http://'+post.short_url, document.title, 'Reading "'+document.title+'"'), 520, 370);
  });
  $(window).scroll(function(){
    if($actions.find('.r_active').length){
      $('#r_close').click();
    }
  });

};

var params = {token: params.token, referrer_id: params.referrer_id, url: url};
if(!on_reading) params.title = window.document.title;

var submit_post = function(data, success){
  $.ajax({
    url: 'http://'+domain+'/post.json',
    dataType: 'jsonp',
    data: data,
    success: function(data, textStatus, jqXHR){
      if(data.meta.status == 400){
        alert('Sorry, an error prevented this page from being posted to Reading');
      } else {
        success(data.response);
      }
    }
  });
};

// submit the inital post on script load
submit_post(params, function(data){
  if(on_reading){
    if(has_token){
      // forward back through to Reading so that the user's
      // token doesn't show up in the referrer
      window.location = 'http://'+domain+'/t/-/'+url;
    } else {
      window.location = url;
    }
  } else {
    post = data.post;
    following = data.following;
    show_overlay();
  }
});

})(jQuery, reading);
