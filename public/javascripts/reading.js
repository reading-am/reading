(function($, params){
if(typeof params.referrer_id == 'undefined') params.referrer_id = 0;

var on_reading = (window.location.host.indexOf('reading.am') >= 0 || window.location.host.indexOf('0.0.0.0') >= 0);

var parse_url = function(){
  var url = window.location.href.split(window.location.host)[1].substring(1);
  if(url.substring(0,2) == 'p/'){
    url = url.substring(url.indexOf('/',2)+1);
  }
  if(url.indexOf('://') == -1) url = 'http://'+url;
  return url;
};

var url   = on_reading ? parse_url() : window.location.href,
    title = on_reading ? '' : window.document.title;

if(on_reading && !params.token) return window.location = url;

var show_overlay = function(){
  var $hand = $('<span>&#9996;</span>').css({'font-size':'56px'}),
      $subtext = $('<span><br>Reading</span>'),
      $loaded_div = $('<div></div>').css({
        'z-index':    '999',
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
  url: 'http://reading.am/post.json',
  dataType: 'jsonp',
  data: params,
  success: function(data, textStatus, jqXHR){
    if(data.meta.status == 400){
      alert('Error');
    } else {
      if(on_reading){
        window.location = url;
      } else {
        show_overlay();
      }
    }
  }
});

})(jQuery, reading);
