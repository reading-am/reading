class AddAuthorizationToHooks < ActiveRecord::Migration
  def change
    add_column :hooks, :authorization_id, :integer
  end
end
