class AddIndexesToTables < ActiveRecord::Migration
  def change
    add_index :users, :username, :unique => true
    add_index :users, :token, :unique => true
    add_index :users, :auth_token, :unique => true
    add_index :domains, :name, :unique => true
    add_index :pages, :url, :unique => true
    add_index :authorizations, [:provider, :uid]
    add_index :hooks, [:user_id, :provider]
  end
end
