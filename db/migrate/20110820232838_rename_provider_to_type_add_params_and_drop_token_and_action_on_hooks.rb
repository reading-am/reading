class RenameProviderToTypeAddParamsAndDropTokenAndActionOnHooks < ActiveRecord::Migration
  def self.up
    add_column :hooks, :params, :string
    Hook.reset_column_information # via: http://stackoverflow.com/questions/972562/rails-wont-let-me-change-records-during-migration
    Hook.find_all_by_provider('url').each do |hook|
      hook.params = {:url => hook.token, :method => hook.action}.to_json
      hook.save
    end
    Hook.find_all_by_provider('hipchat').each do |hook|
      hook.params = {:token => hook.token, :room => hook.action}.to_json
      hook.save
    end
    rename_column :hooks, :provider, :type
    remove_column :hooks, :token
    remove_column :hooks, :action
  end

  def self.down
    remove_column :hooks, :params
    rename_column :hooks, :type, :provider
    add_column :hooks, :token, :string
    add_column :hooks, :action, :string
  end
end
