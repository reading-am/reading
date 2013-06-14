class AddMediaTypeEmbedAndDescriptionToPages < ActiveRecord::Migration
  def change
    add_column :pages, :media_type, :string
    add_column :pages, :embed, :text
    add_column :pages, :description, :text
  end
end
