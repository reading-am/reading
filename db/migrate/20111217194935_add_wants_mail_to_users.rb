class AddWantsMailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wants_mail, :boolean, :default => true
  end
end
