class AddYepNopeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :yn, :boolean
  end
end
