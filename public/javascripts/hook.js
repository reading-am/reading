$(function(){

  var text_field = function(name){
    return $('<div class="field">')
              .append('<label for="hook[params]['+name.toLowerCase()+']">'+name+'</label>')
              .append('<input name="hook[params]['+name.toLowerCase()+']">');
  };
  var select_field = function(name, options){
    var $select = $('<select name="hook[params]['+name.toLowerCase()+']">');
    for(var i = 0; i < options.length; i++){
      $select.append('<option value="'+options[i].toLowerCase()+'">'+options[i]+'</option>');
    }
    return $('<div class="field">')
              .append('<label for="hook[params]['+name.toLowerCase()+']">'+name+'</label>')
              .append($select);
  };

  $("#hook_provider").change(function(){
    var $this = $(this),
        $actions = $('.actions');
    $('.field:not(:first)').remove();
    $('.hook_message').hide();
    $('#'+$this.val()+'_message').show();
    switch($this.val()){
      case 'hipchat':
        $actions.before(text_field('Token'), text_field('Room'));
        break;
      case 'campfire':
        $actions.before(text_field('Token'), text_field('SubDomain'), text_field('Room'));
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
