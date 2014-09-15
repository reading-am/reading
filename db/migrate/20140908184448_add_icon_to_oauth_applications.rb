class AddIconToOauthApplications < ActiveRecord::Migration
  def self.up
    add_attachment :oauth_applications, :icon
  end

  def self.down
    remove_attachment :oauth_applications, :icon
  end
end
