class RenameUrlHookUrlToAddress < ActiveRecord::Migration
  def up
    Hook.where("provider = 'url' AND params LIKE '%\"url\":%'").each do |hook|
      hook.params = hook.read_attribute(:params).sub('"url":', '"address":')
      hook.save
    end
  end

  def down
    Hook.where("provider = 'url' AND params LIKE '%\"address\":%'").each do |hook|
      hook.params = hook.read_attribute(:params).sub('"address":', '"url":')
      hook.save
    end
  end
end
