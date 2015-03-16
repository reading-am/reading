RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    module_path = response.request.env["action_controller.instance"].class.name.deconstantize.underscore
    schema_directory = "#{Dir.pwd}/spec/schemas/#{module_path}"
    schema_path = "#{schema_directory}/#{schema}.json"
    json = JSON.parse(response.body)

    # json-schema will cache the schema with the list: (true|false) value
    # so if you don't clear the cache manually (clear_cache param won't work)
    # it'll always have the list format from the first call
    JSON::Validator.clear_cache
    JSON::Validator.validate!(schema_path, json, strict: true, list: json.is_a?(Array))
  end
end
