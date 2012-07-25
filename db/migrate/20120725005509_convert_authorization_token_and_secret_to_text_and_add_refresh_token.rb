class ConvertAuthorizationTokenAndSecretToTextAndAddRefreshToken < ActiveRecord::Migration
  def change
    add_column :authorizations, :refresh_token, :text
    change_column :authorizations, :token, :text
    change_column :authorizations, :secret, :text
  end
end
