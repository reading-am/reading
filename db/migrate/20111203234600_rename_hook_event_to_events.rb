class RenameHookEventToEvents < ActiveRecord::Migration
  def up
    Hook.all.each do |hook|
      if hook.event == 'all'
        hook.event = '["read","yep","nope"]'
        hook.save
      end
    end
    rename_column :hooks, :event, :events
  end

  def down
    Hook.all.each do |hook|
      if hook.events == '["read","yep","nope"]'
        hook.events = 'all'
        hook.save
      end
    end
    rename_column :hooks, :events, :event
  end
end
