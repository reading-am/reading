class CreateHooks < ActiveRecord::Migration
  def self.up
    create_table :hooks do |t|
      t.string :provider
      t.string :token
      t.string :action
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :hooks
  end
end
