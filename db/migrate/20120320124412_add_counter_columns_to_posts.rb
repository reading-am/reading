class AddCounterColumnsToPosts < ActiveRecord::Migration
  def self.up
    add_column :users, :posts_count, :integer, :default => 0
    User.reset_column_information
    User.all.each do |p|
      User.update_counters p.id, :posts_count => p.posts.length
    end

    add_column :pages, :posts_count, :integer, :default => 0
    Page.reset_column_information
    Page.all.each do |p|
      Page.update_counters p.id, :posts_count => p.posts.length
    end
  end

  def self.down
    remove_column :users, :posts_count
    remove_column :pages, :posts_count
  end
end
