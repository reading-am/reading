class AddEmailWhenMentionedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_when_mentioned, :boolean, :default => true
  end
end
