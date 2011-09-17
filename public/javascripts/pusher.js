// Enable pusher logging - don't include this in production
Pusher.log = function(message) {
  if (window.console && window.console.log) window.console.log(message);
};

// Flash fallback logging - don't include this in production
// WEB_SOCKET_DEBUG = true;

var pusher = new Pusher(pusher_key);
var channel = pusher.subscribe('test_channel');
channel.bind('my_event', function(data) {
  alert(data);
});
