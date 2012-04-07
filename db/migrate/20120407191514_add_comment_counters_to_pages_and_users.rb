class AddCommentCountersToPagesAndUsers < ActiveRecord::Migration
  def change
    add_column :pages, :comments_count, :integer, :default => 0
    add_column :users, :comments_count, :integer, :default => 0
  end
end
