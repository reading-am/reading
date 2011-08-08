(function($, token){

var on_reading = (window.location.host.indexOf('reading.am') >= 0 || window.location.host.indexOf('0.0.0.0') >= 0),
    url   = on_reading ? window.location.href.split(window.location.origin)[1].substring(1) : window.location.href,
    title = on_reading ? '' : window.document.title;

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
        'line-height': '15px',
        'text-align': 'center',
        'display':    'none'
      }).append($hand).append($subtext);
  $('body').prepend($loaded_div);
  $loaded_div.fadeIn().delay(1000).fadeOut(400, function(){ $(this).remove(); });
};

$.ajax({
  url: 'http://0.0.0.0:3000/post.json',
  dataType: 'jsonp',
  data: {token: token, url: url, title: window.document.title},
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

})(jQuery, reading.token);
