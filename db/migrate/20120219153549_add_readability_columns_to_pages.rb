class AddReadabilityColumnsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :r_title, :string

    add_column :pages, :r_excerpt, :string

  end
end
