class AddMediumToPages < ActiveRecord::Migration
  def change
    add_column :pages, :medium, :string
    add_index  :pages, :medium
  end
end
