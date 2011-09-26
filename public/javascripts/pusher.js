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

var pusher = new Pusher(_pusher.key);

for(i = 0; i < _pusher.channels.length; i++){
  var channel = pusher.subscribe(_pusher.channels[i]);
  channel.bind('new_post', function(post){
    $post = $.tmpl('post', post).css({opacity:'0.3'}).addClass('new').prependTo('#content tbody');
    native.notify({
      title: post.user.display_name + ' is reading',
      description: post.title + (post.referrer_post.id ? ' because of ' + post.referrer_post.user.display_name : '')
    });
    if(!window.hasfocus) native.badge('★');
    else $post.fadeTo('medium', 1).removeClass('new');
  });
}

}
