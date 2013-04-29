namespace :orientdb do
  desc "Output a JSON file compatible with the OrientDB Import / Export format."
  task :export => :environment do
    data = {
      "info" => {
        "name" => Rails.configuration.database_configuration[Rails.env]["database"],
        "exporter-version" => 5,
        "engine-version" => "1.3.0",
        "engine-build" => "@BUILD@",
        "storage-config-version" => 4,
        "schema-version" => 4,
        "mvrbtree-version" => 3
      },
      "clusters" => [],
      "schema" => {
        "version" => 31,
        "classes" => []
      },
      "records" => []
    }

    i = 7
    models.each do |model|
      i += 1
      data["clusters"] << {"name" => model.name, "id" => i, "type" => "PHYSICAL"}
      data["schema"]["classes"] << {"name" => model.name, "default-cluster-id" => i, "cluster-ids" => [i]}
    end

    File.open('export.json', 'wb') do |f|
      f.write data.to_json[0..-3]

      i = 7
      first = true
      models.each do |model|
        i += 1
        model.limit(2000).each do |m|
          meta = {"@type" => "d", "@rid" => "##{i}:#{m.id}", "@version" => 0, "@class" => model.name}
          f.write "#{first ? '' : ','}#{meta.merge(m.attributes).to_json}"
          first = false
        end
      end

      f.write "]}"
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
