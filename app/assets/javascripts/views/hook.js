var hook_properties = {
  "actions":[
    {"name":"any", "text":"read, \"yep\" or \"nope\""},
    {"name":"read", "text":"read a page"},
    {"name":"yep",  "text":"say \"yep\""},
    {"name":"nope", "text":"say \"nope\""}
  ],
  "providers":[
    {"name":"Campfire", "params":[
      {"name":"room", "placeholder": "My Room Name"},
      {"name":"token", "placeholder":"12345abcdefg67890abcdefg12345abcdefg6789"}
    ]},
    {"name":"email", "params":[
      {"name":"address", "placeholder":"me@example.com"}
    ]},
    {"name":"Facebook", "params":[
      {"name":"account"}
    ]},
    {"name":"HipChat", "params":[
      {"name":"room", "placeholder":"My Room Name"},
      {"name":"token", "placeholder":"12345abcdefg67890abcdefg12345a"}
    ]},
    {"name":"Twitter", "params":[
      {"name":"account"}
    ]},
    {"name":"URL", "params":[
      {"name":"address", "placeholder":"http://example.com"},
      {
        "name":"method",
        "options":["POST","GET"]
      }
    ]}
  ]
};

var select_field = function(param, scope){
  var name = param.name.toLowerCase().replace(/ /g,'_');
  if(scope) name = scope+'['+name+']';
  var $select = $('<select name="'+name+'">');
  for(var i = 0; i < param.options.length; i++){
    var op = (typeof param.options[i] == 'string' ? {"name":param.options[i]} : param.options[i]);
    $select.append($('<option>').val(op.name.toLowerCase()).text(op.text ? op.text : op.name));
  }
  return $select;
},
text_field = function(param, scope){
  var name = param.name.toLowerCase().replace(/ /g,'_');
  if(scope) name = scope+'['+name+']';
  return $('<span class="field">')
            .append(' <label for="'+name+'">'+param.name+'</label> ')
            .append(' <input type="text" name="'+name+'" placeholder="'+(param.placeholder ? param.placeholder : param.name)+'"> ');
},
build_provider_params = function(params){
  var $prov = $('<span>').attr('id','provider_params');
  for(var i = 0; i < params.length; i++){
    if(i === 1) $prov.append(' using ');
    var func = (params[i].options ? select_field : text_field);
    $prov.append(func(params[i], 'hook[params]'));
  }
  return $prov;
};

$(function(){

  $('#constructor .wrapper')
    .append('When I ')
    .append(select_field({"name":"action", "options":hook_properties.actions}, 'hook'))
    .append(' please post to ')
    .append(select_field({"name":"provider", "options":hook_properties.providers}, 'hook'))
    .append(build_provider_params(hook_properties.providers[0].params));

  var $provider = $("#constructor select[name='hook[provider]']").change(function(){
    $('.footnote').data('url', '/footnotes/'+$provider.val());
    $('#provider_params').replaceWith(build_provider_params(hook_properties.providers[$provider.prop('selectedIndex')].params));
  });

});
