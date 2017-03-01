class RenameProviderToTypeAddParamsAndDropTokenAndActionOnHooks < ActiveRecord::Migration
  def self.up
    add_column :hooks, :params, :string
    Hook.reset_column_information # via: http://stackoverflow.com/questions/972562/rails-wont-let-me-change-records-during-migration
    Hook.where(provider: 'url').each do |hook|
      hook.params = {:url => hook.token, :method => hook.action}.to_json
      hook.save
    end
    Hook.where(provider: 'hipchat').each do |hook|
      hook.params = {:token => hook.token, :room => hook.action}.to_json
      hook.save
    end
    remove_column :hooks, :token
    remove_column :hooks, :action
  end

  def self.down
    remove_column :hooks, :params
    add_column :hooks, :token, :string
    add_column :hooks, :action, :string
  end
end
