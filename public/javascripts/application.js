// write timezone info. From: http://stackoverflow.com/questions/942747/set-current-time-zone-in-rails
if(!($.cookie('timezone'))) {
  current_time = new Date();
  $.cookie('timezone', current_time.getTimezoneOffset(), { path: '/', expires: 10 } );
}

$(function() {
  $("a.external").click(function(){
    var $this = $(this),
        link_host = this.href.split("/")[2],
        document_host = document.location.href.split("/")[2];

    if (link_host != document_host){
      var pre = 'http://0.0.0.0:3000/';
      if(typeof $this.data('base58_id')){
        pre += 'p/'+$this.data('base58_id')+'/';
      }
      window.open(pre+this.href);
      return false;
    }
  });

  $('.bookmarklet').hover(function(){
    var $this = $(this);
    $this.find('span').hide();
    $this.find('a').css('display', 'block');
  }, function(){
    // safari won't let you drag with this in place
    // var $this = $(this);
    // $this.find('span').show();
    // $this.find('a').hide();
  });

});
