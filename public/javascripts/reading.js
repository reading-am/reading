(function($, token){

$.ajax({
  url: 'http://0.0.0.0:3000/post.json',
  dataType: 'jsonp',
  data: {token: token, url: window.location.href, title: window.document.title},
  success: function(data, textStatus, jqXHR){
    if(data.meta.status == 400){
      alert('Error');
    } else {
      alert('succes');
    }
  }
});

})(jQuery, reading.token);
