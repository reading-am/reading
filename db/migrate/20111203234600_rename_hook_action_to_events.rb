class RenameHookActionToEvents < ActiveRecord::Migration
  def up
    rename_column :hooks, :action, :events
    Hook.reset_column_information
    Hook.all.each do |hook|
      if hook.read_attribute(:events).nil?
        hook.events = '["new","yep","nope"]'
        hook.save
      end
    end
  end

  def down
    Hook.all.each do |hook|
      if hook.events == '["new","yep","nope"]'
        hook.events = 'all'
        hook.save
      end
    end
    rename_column :hooks, :action, :event
  end
end
