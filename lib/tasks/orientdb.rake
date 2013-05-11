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
    id = 9
    cluster_ids = {}

    models.each do |model|
      id += 1
      cluster_ids[model.name] = id

      base["clusters"] << {"name" => model.name, "id" => id, "type" => "PHYSICAL"}
      # The order of these props matters. If you add super-class after properties[] it will be ignored
      klass = {
        "name" => model.name,
        "default-cluster-id" => id,
        "cluster-ids" => [id],
        "super-class" => "OGraph#{model.oriental_config[:type].to_s.capitalize}",
        "properties" => []
      }

      model.oriental_config[:attributes].each do |cname|
        assoc = model.reflect_on_association cname
        if !assoc.blank?
          klass["properties"] << {
            "name" => assoc.name,
            "type" => "LINK#{assoc.macro == :has_many ? 'SET' : ''}",
            "linked-class" => assoc.class_name,
            "mandatory" => false,
            "not-null" => false
          }
        else
          column = model.columns.select{|c| c.name == cname.to_s}.first
          klass["properties"] << {
            "name" => column.name,
            "type" => column.type == :text ? "STRING" : column.type.to_s.upcase,
            "mandatory" => !column.null,
            "not-null" => !column.null
          }
        end
      end

      base["schema"]["classes"] << klass
    end

    File.open(cmd_path, "wb") do |f|
      f.write "drop database #{config['url']} #{config['username']} #{config['password']};\n"
      f.write "create database #{config['url']} #{config['username']} #{config['password']} #{config['storage']} #{config['type']};\n"
      f.write "import database #{data_path};\n\n"
    end

    Zlib::GzipWriter.open(data_path) do |gz|
      gz.write to_json(base)[0..-3]

      first = true
      models.each do |model|

        write_assocs = lambda do |m|
          meta = {"@type" => "d", "@rid" => "##{cluster_ids[model.name]}:#{m.id}", "@version" => 0, "@class" => model.name}
          attrs = Hash[model.oriental_config[:attributes].map{|a| [a, m.attributes[a.to_s]] }]

          (model.oriental_config[:attributes] + model.oriental_config[:in] + model.oriental_config[:out]).each do |aname|
            assoc = model.reflect_on_association aname
            if !assoc.blank?
              prop = model.oriental_config[:in].include?(assoc.name) ? "in" : model.oriental_config[:out].include?(assoc.name) ? "out" : assoc.name
              case assoc.macro
              when :has_one, :belongs_to
                if !attrs[assoc.foreign_key].blank?
                  v = "##{cluster_ids[assoc.class_name]}:#{attrs[assoc.foreign_key]}"
                else
                  v = false
                end
              when :has_many
                column = "#{assoc.klass.table_name}.id"
                rows = m.send(assoc.name).select(column)
                rows = rows.where("#{column} <= #{limit}") if limit
                v = rows.map {|row| "##{cluster_ids[assoc.class_name]}:#{row.id}"}
              end

              if !v.blank?
                if prop == 'in' || prop == 'out'
                  attrs[prop] ||= []
                  if v.class == Array
                    attrs[prop] += v
                  else
                    attrs[prop] << v
                  end
                else
                  attrs[prop] = v
                end
              end
            end
          end

          gz.write "#{first ? '' : ','}#{to_json meta.merge(attrs)}"
          first = false
        end

        puts "#{model.name} | #{model.table_name} | #{!limit || model.count < limit ? model.count : limit}"
        if limit
          model.order("id ASC").limit(limit).each &write_assocs
        else
          model.find_each &write_assocs
        end

      end

      gz.write "]}"
    end

    if !pretty_print?
      system "orientdb-console #{cmd_path}"
      File.delete cmd_path, data_path
    end

  end

  def to_json obj
    if pretty_print?
      JSON.pretty_generate obj
    else
      ActiveSupport::JSON.encode obj
    end
  end

  def config
    if @config.blank?
      @config = YAML.load_file("#{Rails.root}/config/orientdb.yml")[Rails.env]
      @config['storage'] ||= 'local'
      @config['type'] ||= 'graph'
    end
    @config
  end

  def limit
    if ENV['limit'].blank? || ENV['limit'] == '0' || ENV['limit'].downcase == 'false'
      false
    else
      ENV['limit'].to_i
    end
  end

  def pretty_print?
    !(ENV['pretty_print'].blank? || ENV['pretty_print'].downcase == 'false')
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
      @models = model_names.map{|i| "#{i}".constantize}.select{|c| defined? c.oriental_config }
    end
    @models
  end

end
