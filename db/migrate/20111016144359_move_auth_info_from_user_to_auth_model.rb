class MoveAuthInfoFromUserToAuthModel < ActiveRecord::Migration
  def up
    User.all.each do |user|
      auth = Authorization.new
      auth.user_id = user.id
      auth.provider = user.provider
      auth.uid = user.uid
      auth.created_at = user.created_at
      auth.save
    end

    remove_column :users, :provider
    remove_column :users, :uid
  end

  def down
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    User.reset_column_information

    User.all.each do |user|
      user.provider = user.authorizations.first.provider
      user.uid      = user.authorizations.first.uid
      user.save
    end
  end
end
