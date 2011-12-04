class CleanUpLegacyOpenGraphHooks < ActiveRecord::Migration
  def up
    Hook.where("provider = 'opengraph'").each do |hook|
      hook.params = nil
      hook.authorization = Authorization.find_by_user_id_and_provider(hook.user_id, 'facebook')
      hook.events = '["new"]'
      hook.save
    end
  end

  def down
  end
end
