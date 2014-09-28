class AddBlockageIndexs < ActiveRecord::Migration
  def change
    add_index :blockages, :blocker_id
    add_index :blockages, :blocked_id
    add_index :blockages, [:blocker_id, :blocked_id], :unique => true
  end
end
