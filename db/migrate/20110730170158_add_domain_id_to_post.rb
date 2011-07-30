class AddDomainIdToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :domain_id, :integer
  end

  def self.down
    remove_column :posts, :domain_id
  end
end
