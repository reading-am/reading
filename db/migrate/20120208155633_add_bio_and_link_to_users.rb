class AddBioAndLinkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bio, :string
    add_column :users, :link, :string
  end
end
