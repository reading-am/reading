class AddRefCounterToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :referring_posts_count, :integer, :default => 0
    Post.reset_column_information
    Post.all.each do |p|
      Post.update_counters p.id, :referring_posts_count => p.referring_posts.length
    end
  end

  def self.down
    remove_column :posts, :referring_posts_count
  end
end
