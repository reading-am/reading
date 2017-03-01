class AddDefaultPermissionsToExistingAuthorizations < ActiveRecord::Migration
  def self.up
    Authorization.where(provider: 'facebook').each do |auth|
      auth.permissions = '["email","offline_access"]'
      auth.save
    end
    Authorization.where(provider: 'twitter').each do |auth|
      if auth.permissions.nil? or !auth.permissions.include? 'write'
        auth.permissions = '["read"]'
        auth.save
      end
    end
  end

  def self.down
  end
end
