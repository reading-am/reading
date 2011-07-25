(function(){

var $ = jQuery,
    token = '***REMOVED***',
    post = function(){
      $.ajax({
        url: 'http://0.0.0.0:3000/post.json',
        dataType: 'jsonp',
        data: {token: token, url: window.location.href, title: window.document.title},
        success: function(data, textStatus, jqXHR){
          if(data.status == 400){
            alert('Error');
          } else {
            alert('succes');
          }
        }
      });
    };

post();

})();
