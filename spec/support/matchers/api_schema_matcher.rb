RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    module_path = response.request.env["action_controller.instance"].class.name.deconstantize.underscore
    schema_directory = "#{Dir.pwd}/spec/schemas/#{module_path}"
    schema_path = "#{schema_directory}/#{schema}.json"
    json = JSON.parse(response.body)
    JSON::Validator.validate!(schema_path, json, strict: true, list: json.is_a?(Array))
  end
end