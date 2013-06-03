class AddFeedPresentToUser < ActiveRecord::Migration
  def change
    add_column :users, :feed_present, :boolean, :default => false
  end
end
