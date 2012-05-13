ø.$(function(){

  var pulse = function(el, c1, c2){
    var $el = ø.$(el);
    $el.animate({'background-color': c1}, 'slow', function(){ $el.animate({'background-color': c2}, 'slow', pulse($el, c1, c2)); });
  };

  ø.$('.post.active a.external').each(function(){
    pulse(this, '#FFF461', '#FFFBCC');
  });

});
