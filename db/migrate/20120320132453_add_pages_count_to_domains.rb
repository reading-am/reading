class AddPagesCountToDomains < ActiveRecord::Migration
  def self.up
    add_column :domains, :pages_count, :integer, :default => 0
    Domain.reset_column_information
    Domain.all.each do |p|
      Domain.update_counters p.id, :pages_count => p.pages.length
    end
  end

  def self.down
    remove_column :domains, :pages_count
  end
end
