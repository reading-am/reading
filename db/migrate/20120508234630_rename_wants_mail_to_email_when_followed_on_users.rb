class RenameWantsMailToEmailWhenFollowedOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :wants_mail, :email_when_followed
  end
end
