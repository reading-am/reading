class AddNotifyWhenMentioned < ActiveRecord::Migration
  def change
    add_column :users, :notify_when_mentioned, :boolean, :default => true
  end
end
