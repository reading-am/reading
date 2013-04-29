namespace :orientdb do
  desc "Output a JSON file compatible with the OrientDB Import / Export format."
  task :export => :environment do
    json = {
      "info" => {
        "name" => Rails.configuration.database_configuration[Rails.env]["database"],
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
      ],
      "schema" => {
        "version" => 31,
        "classes" => [
          {"name" => "OFunction", "default-cluster-id" => 6, "cluster-ids" => [6],
            "properties" => [
              {"name" => "code",        "type" => "STRING"},
              {"name" => "idempotent",  "type" => "BOOLEAN"},
              {"name" => "language",    "type" => "STRING"},
              {"name" => "name",        "type" => "STRING"},
              {"name" => "parameters",  "type" => "EMBEDDEDLIST", "linked-type" => "STRING"}
            ]
          },
          {"name" => "OIdentity",   "default-cluster-id" => -1, "cluster-ids" => [-1], "abstract" => true},
          {"name" => "ORIDs",       "default-cluster-id" => 7,  "cluster-ids" => [7]},
          {"name" => "ORestricted", "default-cluster-id" => -1, "cluster-ids" => [-1], "abstract" => true,
            "properties" => [
              {"name" => "_allow",        "type" => "LINKSET", "linked-class" => "OIdentity"},
              {"name" => "_allowDelete",  "type" => "LINKSET", "linked-class" => "OIdentity"},
              {"name" => "_allowRead",    "type" => "LINKSET", "linked-class" => "OIdentity"},
              {"name" => "_allowUpdate",  "type" => "LINKSET", "linked-class" => "OIdentity"}
            ]
          },
          {"name" => "ORole", "default-cluster-id" => 4, "cluster-ids" => [4], "super-class" => "OIdentity",
            "properties" => [
              {"name" => "inheritedRole", "type" => "LINK", "linked-class" => "ORole"},
              {"name" => "mode",  "type" => "BYTE"},
              {"name" => "name",  "type" => "STRING", "mandatory" => true, "not-null" => true},
              {"name" => "rules", "type" => "EMBEDDEDMAP", "linked-type" => "BYTE"}
            ]
          },
          {"name" => "OUser", "default-cluster-id" => 5, "cluster-ids" => [5], "super-class" => "OIdentity",
            "properties" => [
              {"name" => "name",      "type" => "STRING",   "mandatory" => true, "not-null" => true},
              {"name" => "password",  "type" => "STRING",   "mandatory" => true, "not-null" => true},
              {"name" => "roles",     "type" => "LINKSET",  "linked-class" => "ORole"},
              {"name" => "status",    "type" => "STRING",   "mandatory" => true, "not-null" => true}
            ]
          }
        ]
      }
    }

    i = 7
    models.each do |m|
      i += 1
      json["clusters"] << {"name" => m.table_name, "id" => i, "type" => "PHYSICAL"}
      json["schema"]["classes"] << {"name" => m.table_name, "default-cluster-id" => i, "cluster-ids" => [i]}
    end

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
