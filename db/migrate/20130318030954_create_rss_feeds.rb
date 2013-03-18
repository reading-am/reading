class CreateRssFeeds < ActiveRecord::Migration
  def change
    create_table :rss_feeds do |t|
      t.integer :page_id
      t.text :url

      t.timestamps
    end
  end
end
