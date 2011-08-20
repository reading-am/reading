class AddVerbToDomain < ActiveRecord::Migration
  def self.up
    add_column :domains, :verb, :string
  end

  def self.down
    remove_column :domains, :verb
  end
end
