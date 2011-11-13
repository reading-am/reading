class AddPermissionsColumnToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :permissions, :string
  end
end
