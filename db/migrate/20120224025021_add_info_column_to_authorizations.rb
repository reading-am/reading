class AddInfoColumnToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :info, :text

  end
end
