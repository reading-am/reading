(function(){

var $ = jQuery,
    name = '',
    post = function(){
      $.ajax({
        url: 'http://leppert.me/code/reeeding',
        dataType: 'jsonp',
        data: {name: name, message: '<a href="'+window.location.href+'">'+(window.document.title ? window.document.title : window.location.href)+'</a>'},
        success: function(data, textStatus, jqXHR){
          if(data.error){
            if(data.error == 'missing cookie' || data.error == 'missing name'){
              alert('Go to http://leppert.me/code/reeeding to set your name');
            } else {
              alert(data.error);
            }
          } else {
            // alert('Posted to HipChat');
          }
        }
      });
    };

post();

})();
