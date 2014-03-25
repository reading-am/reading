class AddEmbedToPages < ActiveRecord::Migration
  def change
    add_column :pages, :embed, :text
  end
end
