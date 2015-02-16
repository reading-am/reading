RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    module_path = response.request.env["action_controller.instance"].class.name.deconstantize.underscore
    schema_directory = "#{Dir.pwd}/spec/schemas/#{module_path}"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, response.body, strict: true)
  end
end
