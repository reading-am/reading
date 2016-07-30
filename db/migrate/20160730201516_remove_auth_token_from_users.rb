class RemoveAuthTokenFromUsers < ActiveRecord::Migration[5.0]
  def up
    remove_column :users, :auth_token
  end

  def down
    add_column :users, :auth_token, :string
  end
end
