class AddMediaTypeToPages < ActiveRecord::Migration
  def change
    add_column :pages, :media_type, :string
  end
end
