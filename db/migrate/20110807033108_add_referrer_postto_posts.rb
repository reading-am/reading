class AddReferrerPosttoPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :referrer_post_id, :integer
  end

  def self.down
    remove_column :posts, :referrer_post_id
  end
end
