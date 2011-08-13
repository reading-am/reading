$(function(){
  $('a.follow').click(function(){
    var $this     = $(this),
        follow    = 'Follow',
        disabled  = 'disabled';
    
    if($this.hasClass(disabled)) return false; //Don't take any action if it's already waiting on a call to return

    $this.addClass(disabled);
    $.get($this.attr('href'), function(data){
      if(data == "true"){
        var text = $this.find('span').text() == follow ? "Un"+follow.toLowerCase() : follow,
            href = $this.attr('href');
        $this
          .attr('href', href.replace($this.text(), text.toLowerCase()))
          .text.find('span').(text);
      }
      $this.removeClass(disabled);
    });
    return false;
  });
});
