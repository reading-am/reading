(function($, params){
if(typeof params.referrer_id == 'undefined') params.referrer_id = 0;

var domain      = (window.location.host.indexOf('0.0.0.0') == 0) ? '0.0.0.0:3000' : 'reading.am',
    on_reading  = (window.location.host.indexOf('reading.am') == 0 || window.location.host.indexOf('0.0.0.0') == 0),
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
  var $hand = $('<span>&#9996;</span>').css({'font-size':'56px'}),
      $subtext = $('<span><br>Reading</span>'),
      $loaded_div = $('<div></div>').css({
        'z-index':    '99999999',
        padding:      '20px 10px 5px',
        background:   'yellow',
        position:     'fixed',
        top:          '15px',
        right:        '15px',
        color:        '#000',
        'font-size':  '12px',
        'line-height':'15px',
        'text-align': 'center',
        'display':    'none'
      }).append($hand).append($subtext);
  $('body').prepend($loaded_div);
  $loaded_div.fadeIn().delay(1000).fadeOut(400, function(){ $(this).remove(); });
};

var params = {token: params.token, referrer_id: params.referrer_id, url: url};
if(!on_reading) params.title = window.document.title;

$.ajax({
  url: 'http://'+domain+'/post.json',
  dataType: 'jsonp',
  data: params,
  success: function(data, textStatus, jqXHR){
    if(data.meta.status == 400){
      alert('Error');
    } else {
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
    }
  }
});

})(jQuery, reading);
