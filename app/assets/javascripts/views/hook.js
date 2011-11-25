var hook_properties = {
  "actions":[
    {"name":"any",  "text":"read, \"yep\" or \"nope\"", "perms":["write"]},
    {"name":"read", "text":"read a page", "perms":["write"]},
    {"name":"yep",  "text":"say \"yep\"", "perms":["write"]},
    {"name":"nope", "text":"say \"nope\"", "perms":["write"]}
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
      {"text":"account", "options":current_user.accounts('facebook'), "datatype":"account"}
    ]},
    {"text":"HipChat", "params":[
      {"text":"room", "placeholder":"My Room Name"},
      {"text":"token", "placeholder":"12345abcdefg67890abcdefg12345a"}
    ]},
    {"text":"Twitter", "params":[
      {"text":"account", "options":current_user.accounts('twitter'), "datatype":"account"}
    ]},
    {"text":"URL", "params":[
      {"text":"address", "placeholder":"http://example.com"},
      {"text":"method", "options":["POST","GET"]}
    ]}
  ]
};

var api_urls = {
  twitter:'https://api.twitter.com/1/users/show.json?id=',
  facebook:'https://graph.facebook.com/'
};

var field = function(param, scope, add_label){
  if(!param.name) param.name = param.text.toLowerCase().replace(/ /g,'_');
  if(scope) param.scoped_name = scope+'['+param.name+']';
  if(!param.id) param.id = param.scoped_name.toLowerCase().replace(/\[/g,'_').replace(/\]/g,'');
  var func = (param.options ? select_field : text_field),
      $field = $('<span class="field">');
  if(add_label || typeof add_label == 'undefined'){
    $field.append(' <label for="'+param.id+'">'+param.text+'</label> ');
  }
  return $field.append(func(param));
},
select_field = function(param){
  var $select = $('<select>').attr('name',param.scoped_name).attr('id',param.id);
  if(param.datatype) $select.attr('data-type', param.datatype);
  for(var i = 0; i < param.options.length; i++){
    var op = (typeof param.options[i] == 'string' ? {"text":param.options[i]} : param.options[i]);
    $select.append($('<option>').val(op.text.toLowerCase()).text(op.text ? op.text : op.name));
  }
  if(param.datatype == 'account') $select.append($('<option>').val('new').text('connect a new '+param.datatype));
  return $select;
},
text_field = function(param){
  var $input = (' <input type="text" name="'+param.scoped_name+'" id="'+param.id+'" placeholder="'+(param.placeholder ? param.placeholder : param.name)+'"> ');
  if(param.datatype) $input.attr('data-type', param.datatype);
  return $('<span class="field">').append($input);
},
build_provider = function(params){
  var $prov = $('<span>').attr('id','provider_params');
  for(var i = 0; i < params.length; i++){
    if(i === 1) $prov.append(' using ');
    $prov.append(field(params[i], 'hook[params]'));
  }

  populate_accounts(
    $('#hook_provider').val(),
    $('[data-type="account"] option[value!="new"]', $prov)
  );

  return $prov;
},
populate_accounts = function(provider, selection){
  selection.each(function(){
    var $this = $(this);
    $.ajax({
      url:      api_urls[provider]+$this.text(),
      dataType: 'jsonp',
      success:  function(r){
        if(r.screen_name){
          $this.text(
            (provider == 'twitter' ? '@' : '') + r.screen_name
          );
        } else if(r.username){
          $this.text(r.username);
        } else if(r.name){
          $this.text(r.name);
        }
      }
    });
  });
};

$(function(){

  $('#constructor .wrapper')
    .append('When I ')
    .append(field({"text":"action", "options":hook_properties.actions}, 'hook', false))
    .append(' please post to ')
    .append(field({"text":"provider", "options":hook_properties.providers}, 'hook', false))
    .append(build_provider(hook_properties.providers[0].params));

  var $provider = $("#constructor select[name='hook[provider]']").change(function(){
    $('.footnote').data('url', '/footnotes/'+$provider.val());
    $('#provider_params').replaceWith(build_provider(hook_properties.providers[$provider.prop('selectedIndex')].params));
  });

  populate_accounts('twitter', $('.provider.twitter .account'));
  populate_accounts('facebook', $('.provider.facebook .account'));

});
