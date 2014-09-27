class AddBlockageCounterCacheToUsers < ActiveRecord::Migration
  def change
    add_column :users, :blocking_count, :integer, default: 0
    add_column :users, :blockers_count, :integer, default: 0
  end
end
