class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.text :url
      t.string :title
      t.references :domain

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
