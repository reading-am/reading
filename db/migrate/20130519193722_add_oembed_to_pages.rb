class AddOembedToPages < ActiveRecord::Migration
  def change
    add_column :pages, :oembed, :text
  end
end
