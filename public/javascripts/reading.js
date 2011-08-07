(function($, token){

var show_success = function(){
  var $hand = $('<span>&#9996;</span>').css({'font-size':'56px'}),
      $subtext = $('<span><br>Reading</span>'),
      $loaded_div = $('<div></div>').css({
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
}

$.ajax({
  url: 'http://0.0.0.0:3000/post.json',
  dataType: 'jsonp',
  data: {token: token, url: window.location.href, title: window.document.title},
  success: function(data, textStatus, jqXHR){
    if(data.meta.status == 400){
      alert('Error');
    } else {
      show_success();
    }
  }
});

})(jQuery, (typeof reading != 'undefined' && typeof reading.token != 'undefined') ? reading.token : '');
