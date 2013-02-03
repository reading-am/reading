class AddMetaTagsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :meta_tags, :text
  end
end
