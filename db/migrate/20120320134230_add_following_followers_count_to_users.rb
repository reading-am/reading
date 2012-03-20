class AddFollowingFollowersCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :following_count, :integer, :default => 0
    add_column :users, :followers_count, :integer, :default => 0
    User.reset_column_information
    User.all.each do |p|
      User.update_counters p.id, :following_count => p.following.length
      User.update_counters p.id, :followers_count => p.followers.length
    end
  end

  def self.down
    remove_column :users, :following_count
    remove_column :users, :followers_count
  end
end
