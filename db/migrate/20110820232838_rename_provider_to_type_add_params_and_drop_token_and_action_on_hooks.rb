class RenameProviderToTypeAddParamsAndDropTokenAndActionOnHooks < ActiveRecord::Migration
  def self.up
    add_column :hooks, :params, :string
    rename_column :hooks, :provider, :type
  end

  def self.down
    remove_column :hooks, :params
    rename_column :hooks, :type, :provider
  end
end
