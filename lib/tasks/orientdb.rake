namespace :orientdb do
  desc "Output a JSON file compatible with the OrientDB Import / Export format."
  task :export => :environment do
    json = {
      "info" => {
        "name" => "reading_development", #Rails.application.class.parent_name.downcase,
        "default-cluster-id" => 3,
        "exporter-version" => 5,
        "engine-version" => "1.3.0",
        "engine-build" => "@BUILD@",
        "storage-config-version" => 4,
        "schema-version" => 4,
        "mvrbtree-version" => 3
      },
      "clusters" => [
        {"name" => "internal",  "id" => 0, "type" => "PHYSICAL"},
        {"name" => "default",   "id" => 3, "type" => "PHYSICAL"},
        {"name" => "orole",     "id" => 4, "type" => "PHYSICAL"},
        {"name" => "ouser",     "id" => 5, "type" => "PHYSICAL"},
        {"name" => "ofunction", "id" => 6, "type" => "PHYSICAL"},
        {"name" => "orids",     "id" => 7, "type" => "PHYSICAL"},
      ]
    }
    File.open('export.json', 'wb') do |f|
      f.write JSON.pretty_generate(json)[0..-2]
      f.write "}"
    end
  end

  def base_path
    @base_path ||= Dir.pwd
  end

  def model_path
    @model_path ||= File.join(base_path, 'app/models', '**/*.rb')
  end

  # @return [Array<Class>] classes(models) descending from ActiveRecord::Base
  # from: https://github.com/salesking/json_schema_builder/blob/master/lib/schema_builder/writer.rb
  def models
    Dir.glob(model_path).each {|file| require file rescue nil}
    model_names = Module.constants.select { |c| (eval "#{c}").is_a?(Class) && (eval "#{c}") < ::ActiveRecord::Base }
    model_names.map{|i| "#{i}".constantize}
  end

end
