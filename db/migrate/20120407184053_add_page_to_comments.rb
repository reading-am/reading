class AddPageToComments < ActiveRecord::Migration
  def change
    add_column :comments, :page_id, :integer
    add_index :comments, :page_id
  end
end
