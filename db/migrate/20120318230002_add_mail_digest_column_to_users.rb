class AddMailDigestColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mail_digest, :integer

  end
end
