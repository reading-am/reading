class RemoveUrlTitleAndDomainIdFromPostsAndAddPageId < ActiveRecord::Migration
  def self.up
    remove_column :posts, :url
    remove_column :posts, :title
    remove_column :posts, :domain_id
    add_column :posts, :page_id, :integer
  end

  def self.down
    add_column :posts, :url, :string
    add_column :posts, :title, :string
    add_column :posts, :domain_id, :integer
    remove_column :posts, :page_id
  end
end
