class AddAdditionalOauthFieldsToUsersAndAuthorizations < ActiveRecord::Migration
  def change
    # per: https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :location, :string
    add_column :users, :description, :string
    add_column :users, :image, :string
    add_column :users, :phone, :string
    add_column :users, :urls, :string

    add_column :authorizations, :token, :string
    add_column :authorizations, :secret, :string
  end
end
