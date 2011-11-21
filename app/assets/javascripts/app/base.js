// write timezone info. From: http://stackoverflow.com/questions/942747/set-current-time-zone-in-rails
if(!($.cookie('timezone'))) {
  current_time = new Date();
  $.cookie('timezone', current_time.getTimezoneOffset(), { path: '/', expires: 10 } );
}

window.hasfocus = true;
$(window).focus(function(){
  window.hasfocus = true;
}).blur(function(){
  window.hasfocus = false;
});

window.base58 = encdec();

$(function() {
  $("a.external").on('click', function(){
    var $this = $(this),
        link_host = this.href.split("/")[2],
        document_host = document.location.href.split("/")[2],
        base58_id = (typeof $this.data('base58_id') != 'undefined' ? $this.data('base58_id') : '');

    if (link_host != document_host){
      // old redirect method through reading url
      // var pre = 'http://'+document_host+'/'+(base58_id ? 'p/'+base58_id+'/' : '');
      // window.open(pre+this.href);

      // new AJAX method
      // only log it if they're logged in
      if(current_user.logged_in()){
        $.ajax({
          url: '/post.json',
          data: {
            url: this.href,
            referrer_id: (base58_id ? base58.decode(base58_id) : '')
          }
        });
      }
      window.open(this.href);
      return false;
    }
  });

  $('.bookmarklet').on('hover', function(){
    var $this = $(this);
    $this.find('span').hide();
    $this.find('a').css('display', 'block');
  }, function(){
    // safari won't let you drag with this in place
    // var $this = $(this);
    // $this.find('span').show();
    // $this.find('a').hide();
  });

  $('.footnote').on('click', function(){
    window.open($(this).data('url'), 'footnote', 'location=0,status=0,scrollbars=0,width=900,height=400');
    return false;
  });
});
