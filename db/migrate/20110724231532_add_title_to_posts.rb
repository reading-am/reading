class AddTitleToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :title, :string
  end

  def self.down
    remove_column :posts, :title
  end
end
