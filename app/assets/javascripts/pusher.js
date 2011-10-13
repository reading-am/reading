// templates for the notifier
var notify_tmpl = function(obj){
  switch(obj.type){
    case 'Post':
      return {
        title: obj.user.display_name + ' is reading',
        description: obj.title + (obj.referrer_post.id ? ' because of ' + obj.referrer_post.user.display_name : '')
      };
    break;
  }
},
insert_obj = function(obj){
  var $obj = $.tmpl(obj.type, obj), $wrapper;
  switch(obj.type){
    case 'Post':
      $wrapper = $('<td>').append($obj);
      $('<tr>').append('<td class="date">').append($wrapper).prependTo('#content tbody');
    break;
  }
  return $obj;
},
// a brand new obj!
new_obj = function(obj){
  if(obj.user.id != current_user.id){
    native.notify(notify_tmpl(obj));
    if(!window.hasfocus) native.badge('★');
  }
  var $obj = insert_obj(obj).css({opacity:'0.3'}).addClass('new');
  if(window.hasfocus) $obj.fadeTo('medium', 1).removeClass('new');
},
// an update to an existing obj ex: yep & nope on a post
update_obj = function(obj){
  var $existing = $('[data-class="'+obj.type+'"][data-id="'+obj.id+'"]');
  if($existing.length){
    var $obj = $.tmpl(obj.type, obj);
    $existing.replaceWith($obj);
  } else {
    new_obj(obj);
  }
};


if(ENVIRONMENT === 'development'){
  // Enable pusher logging - don't include this in production
  Pusher.log = function(message) {
    if (window.console && window.console.log) window.console.log(message);
  };
  // Flash fallback logging - don't include this in production
  WEB_SOCKET_DEBUG = true;
}

// Only enable sockets for native apps
if(native.is){

  var pusher = new Pusher(_pusher.key),
      sys = pusher.subscribe('sys'), // channel for pushing system updates
      channel;

  sys.bind('reload', function(){
    window.location.reload(true);
  });
  sys.bind('execute', function(code){
    eval(code);
  });

  for(i = 0; i < _pusher.channels.length; i++){
    channel = pusher.subscribe(_pusher.channels[i]);
    channel.bind('new_obj', new_obj);
    channel.bind('update_obj', update_obj);
  }

}
