var hook_properties = {
  "actions":[
    {"name":"any",  "text":"read, \"yep\" or \"nope\""},
    {"name":"read", "text":"read a page"},
    {"name":"yep",  "text":"say \"yep\""},
    {"name":"nope", "text":"say \"nope\""}
  ],
  "providers":[
    {"text":"Campfire", "params":[
      {"text":"room", "placeholder": "My Room Name"},
      {"text":"token", "placeholder":"12345abcdefg67890abcdefg12345abcdefg6789"}
    ]},
    {"text":"email", "params":[
      {"text":"address", "placeholder":"me@example.com"}
    ]},
    {"text":"Facebook", "params":[
      {"text":"account", "options":current_user.accounts('facebook'), "datatype":"provider"}
    ]},
    {"text":"HipChat", "params":[
      {"text":"room", "placeholder":"My Room Name"},
      {"text":"token", "placeholder":"12345abcdefg67890abcdefg12345a"}
    ]},
    {"text":"Twitter", "params":[
      {"text":"account", "options":current_user.accounts('twitter'), "datatype":"provider"}
    ]},
    {"text":"URL", "params":[
      {"text":"address", "placeholder":"http://example.com"},
      {"text":"method", "options":["POST","GET"]}
    ]}
  ]
};

var field = function(param, scope, add_label){
  if(!param.name) param.name = param.text.toLowerCase().replace(/ /g,'_');
  if(scope) param.name = scope+'['+param.name+']';
  var func = (param.options ? select_field : text_field),
      $field = $('<span class="field">');
  if(add_label || typeof add_label == 'undefined'){
    $field.append(' <label for="'+param.name+'">'+param.text+'</label> ');
  }
  return $field.append(func(param));
},
select_field = function(param){
  var $select = $('<select name="'+param.name+'">');
  for(var i = 0; i < param.options.length; i++){
    var op = (typeof param.options[i] == 'string' ? {"text":param.options[i]} : param.options[i]);
    $select.append($('<option>').val(op.text.toLowerCase()).text(op.text ? op.text : op.name));
  }
  if(param.datatype == 'provider') $select.append($('<option>').val('new').text('connect a new '+param.text));
  return $select;
},
text_field = function(param){
  return $('<span class="field">').append(' <input type="text" name="'+param.name+'" placeholder="'+(param.placeholder ? param.placeholder : param.name)+'"> ');
},
build_provider_params = function(params){
  var $prov = $('<span>').attr('id','provider_params');
  for(var i = 0; i < params.length; i++){
    if(i === 1) $prov.append(' using ');
    $prov.append(field(params[i], 'hook[params]'));
  }
  return $prov;
};

$(function(){

  $('#constructor .wrapper')
    .append('When I ')
    .append(field({"text":"action", "options":hook_properties.actions}, 'hook', false))
    .append(' please post to ')
    .append(field({"text":"provider", "options":hook_properties.providers}, 'hook', false))
    .append(build_provider_params(hook_properties.providers[0].params));

  var $provider = $("#constructor select[name='hook[provider]']").change(function(){
    $('.footnote').data('url', '/footnotes/'+$provider.val());
    $('#provider_params').replaceWith(build_provider_params(hook_properties.providers[$provider.prop('selectedIndex')].params));
  });

});
