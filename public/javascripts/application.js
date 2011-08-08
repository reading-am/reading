// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  $("a").click(function(){
    var $this = $(this),
        link_host = this.href.split("/")[2],
        document_host = document.location.href.split("/")[2];

    if (link_host != document_host){
      var pre = 'http://reading.am/';
      if(typeof $this.data('base58_id')){
        pre += 'p/'+$this.data('base58_id')+'/';
      }
      window.open(pre+this.href);
      return false;
    }
  });

  var bookmarklet_hover = function(){
    var $this = $('a.bookmarklet'),
        alt = $this.attr('alt');
    $this
      .attr('alt', $this.text())
      .text(alt);
  };
  bookmarklet_hover(); // call this on load so that the browser bookmark bar shows the right text

  $("a.bookmarklet").hover(bookmarklet_hover, bookmarklet_hover);

  $("#hook_provider").change(function(){
    $this = $(this);
    $('.field').show();
    $('.hook_message').hide();
    $('#'+$this.val()+'_message').show();
    switch($this.val()){
      case 'hipchat':
        $('label[for="hook_token"]').text('Token');
        $('label[for="hook_action"]').text('Room');
        $('#hook_action').show().val('');
        $('#action_select').hide();
        break;
      case 'url':
        $('label[for="hook_token"]').text('URL');
        $('label[for="hook_action"]').text('Method');
        $('#hook_action').hide().val($('#action_select').val());
        $('#action_select').show();
        break;
    }
  });

  $('#action_select').change(function(){
    $('#hook_action').val($(this).val());
  });

});
