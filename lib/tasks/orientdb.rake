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

    limit = 5
    db_name   = Rails.configuration.database_configuration[Rails.env]["database"]
    data_path = "/tmp/#{db_name}_data.json.gz"
    cmd_path  = "/tmp/#{db_name}_commands"

    # Create the basic structure of the output
    base = {
      "info" => {
        "name" => db_name,
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

    selected_models.each do |model|
      id += 1
      cluster_ids[model.name] = id

      base["clusters"] << {"name" => model.name, "id" => id, "type" => "PHYSICAL"}
      klass = {"name" => model.name, "default-cluster-id" => id, "cluster-ids" => [id], "properties" => []}

      belongs_to[model] = {}
      model.reflect_on_all_associations.each do |assoc|
        next if !selected_models.include?(assoc.klass)

        if assoc.options[:through].nil? || through? ||
          (remove_join_tables? && (join_tables.include?(assoc.options[:through]) || join_assoc[model].include?(assoc.options[:through])))

          case assoc.macro
          when :has_many
            klass["properties"] << {
              "name" => assoc.name,
              "type" => "LINKSET",
              "linked-class" => assoc.class_name,
              "mandatory" => false,
              "not-null" => false
            }
          when :has_one, :belongs_to
            belongs_to[model][assoc.foreign_key] = assoc
          end
        end
      end

      model.columns_hash.each do |column|
        column = column[1]
        assoc = belongs_to[model][column.name]
        next if !assoc.nil? && !selected_models.include?(assoc.klass)

        klass["properties"] << {
          "name" => assoc.nil? ? column.name : assoc.name,
          "type" => (assoc.nil? ? column.type == :text ? "STRING" : column.type.to_s.upcase : "LINK"),
          "mandatory" => !column.null,
          "not-null" => !column.null
        }
        klass["properties"].last["linked-class"] = assoc.class_name unless assoc.nil?
      end

      base["schema"]["classes"] << klass
    end

    File.open(cmd_path, "wb") do |f|
      f.write "drop database #{ENV['db'].split(' ')[0..2].join(' ')};\n"
      f.write "create database #{ENV['db']};\n"
      f.write "import database #{data_path};\n\n"

      selected_models.each do |model|

        model.reflect_on_all_associations.each do |assoc|
          if assoc.options[:through].nil? && selected_models.include?(assoc.klass)
            case assoc.macro
            when :has_many
              f.write "CREATE LINK #{assoc.name} TYPE LINKSET FROM #{assoc.class_name}.#{assoc.foreign_key} TO #{model.name}.id INVERSE;\n\n"
            when :has_one, :belongs_to
              f.write "CREATE LINK #{assoc.name} TYPE LINK FROM #{model.name}.#{assoc.foreign_key} TO #{assoc.class_name}.id;\n"
              f.write "UPDATE #{model.name} REMOVE #{assoc.foreign_key};\n\n"
            end
          end
        end

      end
    end

    Zlib::GzipWriter.open(data_path) do |gz|
      gz.write to_json(base)[0..-3]

      first = true
      selected_models.each do |model|

        puts "#{model.name} | #{model.table_name} | #{model.count}"

        model.order("id ASC").limit(limit).each do |m|
          meta = {"@type" => "d", "@rid" => "##{cluster_ids[model.name]}:#{m.id}", "@version" => 0, "@class" => model.name}
          attrs = m.attributes

          if through? || remove_join_tables?
            model.reflect_on_all_associations.each do |assoc|
              if !assoc.options[:through].nil? && selected_models.include?(assoc.klass) &&
                (through? || (remove_join_tables? && (join_tables.include?(assoc.options[:through]) || join_assoc[model].include?(assoc.options[:through]))))

                case assoc.macro
                when :has_one
                  attrs[assoc.name] = "##{cluster_ids[assoc.class_name]}:#{attrs[assoc.foreign_key]}" unless attrs[assoc.foreign_key].blank?
                  attrs.delete(assoc.foreign_key)
                when :has_many
                  attrs[assoc.name] = m.send(assoc.name).select("#{assoc.klass.table_name}.id").map do |x|
                    "##{cluster_ids[assoc.class_name]}:#{x.id}" if x.id <= limit
                  end
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

  def join_models
    @join_models ||= models.select {|m| is_a_join_table?(m)}
  end

  def join_tables
    @join_tables ||= join_models.map {|m| m.table_name.to_sym}
  end

  def join_assoc
    if @join_assoc.blank?
      @join_assoc = {}
      models.each do |m|
        @join_assoc[m] = m.reflect_on_all_associations.select {|a| join_tables.include?(a.table_name.to_sym)}.map! {|a| a.name}
      end
    end
    @join_assoc
  end

  def through?
    !(ENV['through'].blank? || ENV['through'].downcase == 'false')
  end

  def remove_join_tables?
    !(ENV['remove_join_tables'].blank? || ENV['remove_join_tables'].downcase == 'false')
  end

  def is_a_join_table? model
    columns = model.reflect_on_all_associations(:belongs_to).map {|assoc| assoc.foreign_key}
    columns.length == 2 && model.columns.select {|c| !(columns + ['id','created_at','updated_at']).include?(c.name)}.blank?
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

  # from: https://github.com/salesking/json_schema_builder/blob/master/lib/schema_builder/writer.rb
  def models
    if @models.blank?
      Dir.glob(model_path).each {|file| require file rescue nil}
      model_names = Module.constants.select { |c| (eval "#{c}").is_a?(Class) && (eval "#{c}") < ::ActiveRecord::Base }
      @models = model_names.map{|i| "#{i}".constantize}
    end
    @models
  end

  def selected_models
    if @selected_models.blank?
      if remove_join_tables?
        @selected_models = models.select {|m| !join_models.include?(m)}
      else
        @selected_models = models
      end

      if !ENV['models'].blank?
        i = ENV['models'].downcase.split(',').collect(&:strip)
        @selected_models.select! {|m| i.include?(m.name.downcase)}
      end
    end

    @selected_models
  end

end
