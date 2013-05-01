namespace :orientdb do
  desc "Output a JSON file compatible with the OrientDB Import / Export format."
  task :export => :environment do

    # Monkey patch the JSON output of dates
    # This is the only format I found that works with OrientDB
    class ActiveSupport::TimeWithZone
      def as_json(options = {})
        strftime("%Y-%m-%d %H:%M:%S:%L")
      end
    end

    # Create the basic structure of the output
    base = {
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

    # pad the id to allow room for the system ids required by orient
    id = 10
    cluster_ids = {}
    belongs_to = {}

    models.each do |model|
      id += 1
      cluster_ids[model.name] = id

      base["clusters"] << {"name" => model.name, "id" => id, "type" => "PHYSICAL"}
      clss = {"name" => model.name, "default-cluster-id" => id, "cluster-ids" => [id], "properties" => []}

      # find the ActiveRecord associations and add them to the schema
      belongs_to[model] = {}
      model.reflect_on_all_associations(:belongs_to).each do |assoc|
        belongs_to[model][assoc.foreign_key] = assoc
      end

      model.columns_hash.each do |column|
        column = column[1]
        assoc = belongs_to[model][column.name]

        clss["properties"] << {
          "name" => assoc.nil? ? column.name : assoc.name,
          "type" => (assoc.nil? ? column.type == :text ? "STRING" : column.type.to_s.upcase : "LINK"),
          "mandatory" => !column.null,
          "not-null" => !column.null
        }
        clss["properties"].last["linked-class"] = assoc.class_name unless assoc.nil?
      end

      model.reflect_on_all_associations(:has_many).each do |assoc|
        clss["properties"] << {
          "name" => assoc.name,
          "type" => "LINKSET",
          "linked-class" => assoc.class_name,
          "mandatory" => false,
          "not-null" => false
        }
      end

      base["schema"]["classes"] << clss
    end

    File.open('export.json', 'wb') do |f|
      f.write to_json(base)[0..-3]

      first = true
      models.each do |model|
        model.find_each do |m|
          meta = {"@type" => "d", "@rid" => "##{cluster_ids[model.name]}:#{m.id}", "@version" => 0, "@class" => model.name}
          attrs = m.attributes

          model.reflect_on_all_associations(:belongs_to).each do |assoc|
            attrs[assoc.name] = "##{cluster_ids[assoc.class_name]}:#{attrs[assoc.foreign_key]}" unless attrs[assoc.foreign_key].blank?
            attrs.delete(assoc.foreign_key)
          end

          model.reflect_on_all_associations(:has_many).each do |assoc|
            attrs[assoc.name] = m.send(assoc.name).select("#{assoc.class_name.constantize.table_name}.id").map {|x| "##{cluster_ids[assoc.class_name]}:#{x.id}"}
          end

          f.write "#{first ? '' : ','}#{to_json meta.merge(attrs)}"
          first = false
        end
      end

      f.write "]}"
    end

  end

  def to_json obj
    #JSON.pretty_generate obj
    ActiveSupport::JSON.encode obj
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
