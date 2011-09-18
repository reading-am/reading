if(ENVIRONMENT === 'development'){
  // Enable pusher logging - don't include this in production
  Pusher.log = function(message) {
    if (window.console && window.console.log) window.console.log(message);
  };
  // Flash fallback logging - don't include this in production
  WEB_SOCKET_DEBUG = true;
}

var pusher = new Pusher(_pusher.key);

for(i = 0; i < _pusher.channels.length; i++){
  var channel = pusher.subscribe(_pusher.channels[i]);
  channel.bind('new_post', function(post) {
    native.notify({title: post.user.display_name+' is reading', description: post.title});
  });
}

