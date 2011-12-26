(function($, params){

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
        'font-size:16px;'+
        'line-height:normal;'+
        'text-align:left;'+
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
        'width:315px;'+
        'padding:25px 30px;'+
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
      '#r_am a {'+
        'text-decoration:underline;'+
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
      '#r_head, #r_upgrade a {'+
        'font-size:22px;'+
      '}'+
      '#r_upgrade {'+
        'margin:10px 0;'+
        'width:100%;'+
      '}'+
      '#r_upgrade a {'+
        'display:block;'+
        'width:100%;'+
        'text-align:center;'+
      '}'+
      '#r_details {'+
        'line-height:20px;'+
      '}'+
    '</style>').appendTo('head'),
    bookmarklet = "javascript:(function(){window.reading={token:'"+reading.token+"',platform:'bookmarklet'};var head=document.getElementsByTagName('head')[0],script=document.createElement('script');script.src='http://reading.am/assets/bookmarklet/loader.js';head.appendChild(script);})()"
    $subtext = $('<div>'+
                  '<div id="r_head">&#9996; It\'s time to upgrade your bookmarklet. Fantastic.</div>'+
                  '<div id="r_upgrade"><a href="'+bookmarklet+'" class="r_active">Drag me to your bookmark bar</a></div>'+
                  '<div id="r_details">Don\'t forget to delete your old bookmarklet. Find <a href="http://writing.reading.am/post/14787029326/all-i-want-for-christmas-is-a-new-bookmarklet-that" target=_blank>details here</a> or <a href="mailto:hello@reading.am">help here</a>.</div>'+
                '</div>'),
    $wrapper = $('<div id="r_wrp">').append($subtext),
    $reading = $('<div id="r_am">').append($wrapper);

$('body').prepend($reading);
$('#r_upgrade a').mouseover(function(){
  $(this).html('&#9996; Reading');
});

$reading.fadeIn(500);

})(jQuery, reading);
