namespace :orientdb do
  desc "Output a JSON file compatible with the OrientDB Import / Export format."
  task :export => :environment do

    class ActiveSupport::TimeWithZone
      def as_json(options = {})
        strftime("%Y-%m-%d %H:%M:%S:%L")
      end
    end

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
    cluster_ids = {}
    belongs_to = {}
    models.each do |model|
      i += 1
      cluster_ids[model.name] = i
      data["clusters"] << {"name" => model.name, "id" => i, "type" => "PHYSICAL"}

      c = {"name" => model.name, "default-cluster-id" => i, "cluster-ids" => [i], "properties" => []}

      belongs_to[model] = {}
      model.reflect_on_all_associations(:belongs_to).each do |assc|
        belongs_to[model][assc.foreign_key] = assc
      end
      model.columns_hash.each do |column|
        column = column[1]
        prop = {"name" => column.name, "type" => (column.type == :text ? "STRING" : column.type.to_s.upcase), "mandatory" => !column.null, "not-null" => column.null}
        if !belongs_to[model][column.name].nil?
          prop["name"] = belongs_to[model][column.name].name
          prop["type"] = "LINK"
          prop["linked-class"] = belongs_to[model][column.name].class_name
        end
        c["properties"] << prop
      end
      data["schema"]["classes"] << c
    end

    File.open('export.json', 'wb') do |f|
      f.write to_json(data)[0..-3]

      i = 7
      first = true
      models.each do |model|
        i += 1
        model.order("id ASC").limit(5).each do |m|
          meta = {"@type" => "d", "@rid" => "##{i}:#{m.id}", "@version" => 0, "@class" => model.name}
          attrs = m.attributes
          belongs_to[model].each do |k,v|
            attrs[v.name] = "##{cluster_ids[v.class_name]}:#{attrs[k]}" unless attrs[k].blank?
            attrs.delete(k)
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
