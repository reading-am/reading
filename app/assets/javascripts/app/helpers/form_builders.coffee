define ["jquery"], ($) ->

  field: (param, scope, add_label=true) ->
    if param.scope?
      $scope = $("<span>")
      $scope.append(@field(p, "#{scope}[#{param.scope}]")) for p in param.params
      return $scope
    else
      param.name = param.text.toLowerCase().replace(RegExp(" ", "g"), "_")  unless param.name?
      param.value = "" unless param.value?
      param.scoped_name = scope + "[" + param.name + "]"  if scope
      param.id = param.scoped_name.toLowerCase().replace(/\[/g, "_").replace(/\]/g, "")  unless param.id?
      if param.type is "hidden"
        @hidden_field(param)
      else
        func = (if param.options then @select_field else @text_field)
        $field = $("<span class=\"control-group\">")
        $field.append " <label for=\"#{param.id}\">#{param.text}</label> " if add_label and param.text?
        $field.append func(param)

  select_field: (param) ->
    $select = $("<select>").attr("name", param.scoped_name).attr("id", param.id)
    $select.attr "data-type", param.datatype if param.datatype
    $select.attr "data-src", param.src if param.src
    i = 0

    while i < param.options.length
      op = (if typeof param.options[i] is "string" then text: param.options[i] else param.options[i])
      op.value = op.text.toLowerCase()  unless op.value
      $select.append $("<option>").val(op.value).text((if op.text then op.text else op.value))
      i++
    $select.append $("<option>").val("new").text("+ connect new") if param.datatype is "account"

    $select

  text_field: (param) ->
    $input = (" <input type=\"text\" name=\"#{param.scoped_name}\" id=\"#{param.id}\" placeholder=\"#{(if param.placeholder then param.placeholder else param.name)}\"> ")
    $input.attr "data-type", param.datatype  if param.datatype
    $("<span class=\"control-group\">").append $input

  hidden_field: (param) ->
    $("<input type=\"hidden\" name=\"#{param.scoped_name}\" id=\"#{param.id}\" value=\"#{param.value}\">")
