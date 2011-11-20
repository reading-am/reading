class AddActionToHooks < ActiveRecord::Migration
  def change
    add_column :hooks, :action, :string
  end
end
