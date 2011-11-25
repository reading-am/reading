class SetDefaultActionForExistingHooks < ActiveRecord::Migration
  def self.up
    Hook.all.each do |hook|
      if hook.action.nil?
        hook.action = 'all'
        hook.save
      end
    end
  end

  def self.down
  end
end
