class AddDefaultPermissionsToExistingAuthorizations < ActiveRecord::Migration
  def self.up
    Authorization.find_all_by_provider('facebook').each do |auth|
      auth.permissions = '["email","offline_access"]'
      auth.save
    end
    Authorization.find_all_by_provider('twitter').each do |auth|
      auth.permissions = '["read"]'
      auth.save
    end
  end

  def self.down
  end
end
