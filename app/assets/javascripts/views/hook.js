$(function(){

  var text_field = function(name){
    return $('<div class="field">')
              .append('<label for="hook[params]['+name.toLowerCase().replace(/ /g,'_')+']">'+name+'</label>')
              .append('<input name="hook[params]['+name.toLowerCase().replace(/ /g,'_')+']">');
  },
  select_field = function(name, options){
    var $select = $('<select name="hook[params]['+name.toLowerCase().replace(/ /g,'_')+']">');
    for(var i = 0; i < options.length; i++){
      $select.append('<option value="'+options[i].toLowerCase().replace(/ /g,'_')+'">'+options[i]+'</option>');
    }
    return $('<div class="field">')
              .append('<label for="hook[params]['+name.toLowerCase().replace(/ /g,'_')+']">'+name+'</label>')
              .append($select);
  };

  $("#hook_provider").change(function(){
    var $this = $(this),
        $actions = $('.actions');
    $('.field:not(:first)').remove();
    $('.footnote').data('url', '/footnotes/'+$this.val());
    switch($this.val()){
      case 'hipchat':
        $actions.before(text_field('Token'), text_field('Room'));
        break;
      case 'campfire':
        $actions.before(text_field('Token'), text_field('Subdomain'), text_field('Room'));
        break;
      case 'opengraph':
        if(has_facebook){
          $actions.before(
            $('<div class="field">')
                .append('<label for="hook[params][when]">Press Create!</label>')
                .append('<input name="hook[params][when]" val="on_post" type="hidden">')
          );
        } else {
          $actions.before('<div class="field"><a href="/auth/facebook">First, click here to connect your Facebook account</a></div>');
        }
        break;
      case 'url':
        $actions.before(text_field('URL'), select_field('Method', ['GET', 'POST']));
        break;
    }
  });

  $('#action_select').change(function(){
    $('#hook_action').val($(this).val());
  });

});
