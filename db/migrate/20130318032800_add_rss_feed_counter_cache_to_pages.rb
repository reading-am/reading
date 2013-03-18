class AddRssFeedCounterCacheToPages < ActiveRecord::Migration
  def change
    add_column :pages, :rss_feed_count, :integer, :default => 0
  end
end
