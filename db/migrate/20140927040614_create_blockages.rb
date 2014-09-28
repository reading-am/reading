class CreateBlockages < ActiveRecord::Migration
  def change
    create_table :blockages do |t|
      t.integer :blocker_id
      t.integer :blocked_id

      t.timestamps
    end
  end
end
