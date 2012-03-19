class AddAccessToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access, :integer

  end
end
