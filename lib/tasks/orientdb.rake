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
    data_path = "/tmp/#{base['info']['name']}_data.json.gz"
    cmd_path = "/tmp/#{base['info']['name']}_commands"

    models.each do |model|
      id += 1
      cluster_ids[model.name] = id

      base["clusters"] << {"name" => model.name, "id" => id, "type" => "PHYSICAL"}
      clss = {"name" => model.name, "default-cluster-id" => id, "cluster-ids" => [id], "properties" => []}

      model.reflect_on_all_associations(:has_many).each do |assoc|
        if assoc.options[:through].nil? || through?
          clss["properties"] << {
            "name" => assoc.name,
            "type" => "LINKSET",
            "linked-class" => assoc.class_name,
            "mandatory" => false,
            "not-null" => false
          }
        end
      end

      # find the ActiveRecord associations and add them to the schema
      belongs_to[model] = {}
      model.reflect_on_all_associations(:has_one).concat(model.reflect_on_all_associations(:belongs_to)).each do |assoc|
        if assoc.options[:through].nil? || through?
          belongs_to[model][assoc.foreign_key] = assoc
        end
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

      base["schema"]["classes"] << clss
    end

    File.open(cmd_path, "wb") do |f|
      f.write "drop database #{ENV['db'].split(' ')[0..2].join(' ')};\n"
      f.write "create database #{ENV['db']};\n"
      f.write "import database #{data_path};\n\n"

      models.each do |model|
        model.reflect_on_all_associations(:has_many).each do |assoc|
          if assoc.options[:through].nil?
            f.write "CREATE LINK #{assoc.name} TYPE LINKSET FROM #{assoc.class_name}.#{assoc.foreign_key} TO #{model.name}.id INVERSE;\n\n"
          end
        end

        model.reflect_on_all_associations(:has_one).concat(model.reflect_on_all_associations(:belongs_to)).each do |assoc|
          if assoc.options[:through].nil?
            f.write "CREATE LINK #{assoc.name} TYPE LINK FROM #{model.name}.#{assoc.foreign_key} TO #{assoc.class_name}.id;\n"
            f.write "UPDATE #{model.name} REMOVE #{assoc.foreign_key};\n\n"
          end
        end
      end
    end

    Zlib::GzipWriter.open(data_path) do |gz|
      gz.write to_json(base)[0..-3]

      first = true
      limit = 5
      models.each do |model|

        puts "#{model.name} | #{model.table_name} | #{model.count}"


        model.order("id ASC").limit(limit).each do |m|
          meta = {"@type" => "d", "@rid" => "##{cluster_ids[model.name]}:#{m.id}", "@version" => 0, "@class" => model.name}
          attrs = m.attributes

          if through?
            model.reflect_on_all_associations(:has_one).each do |assoc|
              if !assoc.options[:through].nil?
                attrs[assoc.name] = "##{cluster_ids[assoc.class_name]}:#{attrs[assoc.foreign_key]}" unless attrs[assoc.foreign_key].blank?
                attrs.delete(assoc.foreign_key)
              end
            end

            model.reflect_on_all_associations(:has_many).each do |assoc|
              if !assoc.options[:through].nil?
                attrs[assoc.name] = m.send(assoc.name).select("#{assoc.class_name.constantize.table_name}.id").map do |x|
                  "##{cluster_ids[assoc.class_name]}:#{x.id}" if x.id <= limit
                end
              end
            end
          end

          gz.write "#{first ? '' : ','}#{to_json meta.merge(attrs)}"
          first = false
        end
      end

      gz.write "]}"
    end

    system "orientdb-console #{cmd_path}"
    File.delete cmd_path, data_path

  end

  def through?
    !(ENV['through'].blank? || ENV['through'].downcase == 'false')
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
