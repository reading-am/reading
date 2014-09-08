class AddAuxInfoToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :website, :string
    add_column :oauth_applications, :description, :text
    add_column :oauth_applications, :app_store_url, :string
    add_column :oauth_applications, :play_store_url, :string
  end
end
