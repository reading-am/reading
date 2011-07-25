(function(){

var $ = jQuery,
    token = '1a6e0f949ab9739b3e92fce83de2ac4b',
    post = function(){
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
    };

post();

})();
