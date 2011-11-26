class RenameHooksActionToEvent < ActiveRecord::Migration
  def change
    rename_column :hooks, :action, :event
  end
end
