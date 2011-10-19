(function($, params){
if(typeof params.referrer_id == 'undefined') params.referrer_id = 0;

var host        = window.location.host,
    domain = '0.0.0.0:3000', // for dev
    // domain      = host.indexOf('0.0.0.0') == 0 ? '0.0.0.0:3000' : host.indexOf('staging.reading.am') == 0 ? 'staging.reading.am' : 'reading.am',
    on_reading  = (host.indexOf('reading.am') == 0 || host.indexOf('staging.reading.am') == 0 || host.indexOf('0.0.0.0') == 0),
    pass_thru   = (params.token == '-' || (on_reading && !params.token)), //don't post anything, just forward on
    has_token   = false;

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
          'font-variant:normal;'+
          'letter-spacing:normal;'+
        '}'+
        '#r_am {'+
          'display:none;'+
          'z-index:99999999;'+
          'padding:10px 10px 5px;'+
          'margin:0;'+
          'background:yellow;'+
          'position:fixed;'+
          'top:15px;'+
          'right:15px;'+
          'overflow:hidden;'+
          'height:60px;'+
          'width:50px;'+
        '}'+
        '#r_icon {'+
          'font-size:56px;'+
          'line-height:0;'+
          'margin:18px 0 25px;'+
        '}'+
        '#r_actions {'+
          'margin:10px 0 0;'+
          'width:77px;'+
        '}'+
        '#r_actions a:hover, .r_active {'+
          'background:#FFF;'+
        '}'+
        '#r_actions .r_inactive {'+
          'text-decoration:line-through;'+
        '}'+
        '#r_close {'+
          'font-size:9px;'+
        '}'+
      '</style>').appendTo('head');
      $icon = $('<div id="r_icon">&#9996;</div>'),
      $subtext = $('<div>Reading</div>'),
      $actions = $('<div id="r_actions"><a href="#" id="r_yep">Yep</a> . <a href="#" id="r_nope">Nope</a> | <a href="#" id="r_close">&#10005;</a></div>'),
      $wrapper = $('<div id="r_am"></div>').append($icon).append($subtext).append($actions);
  $('body').prepend($wrapper);
  $wrapper.fadeIn(500, function(){
    $wrapper.delay(1000).animate({height:'14px', width:'77px'});
    $icon.delay(1000).animate({'margin-top':'-52px'});
  });
  $('#r_close').click(function(){
    $wrapper.fadeOut(400, function(){ $wrapper.remove(); });
    return false;
  });
  $('#r_yep, #r_nope').click(function(){
    var $this = $(this),
        $close= $('#r_close'),
        i = 0,
        shapes = ['✻','✼','✽','✾'],
        loading = setInterval(function(){
          $close
            .text(shapes[i]);
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
      $close.text('✕');
    });
    return false;
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
        alert('Error');
      } else {
        success();
      }
    }
  });
};

// submit the inital post on script load
submit_post(params, function(){
  if(on_reading){
    if(has_token){
      // forward back through to Reading so that the user's
      // token doesn't show up in the referrer
      window.location = 'http://'+domain+'/t/-/'+url;
    } else {
      window.location = url;
    }
  } else {
    show_overlay();
  }
});

})(jQuery, reading);
