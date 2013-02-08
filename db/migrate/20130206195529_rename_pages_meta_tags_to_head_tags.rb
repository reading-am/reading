class RenamePagesMetaTagsToHeadTags < ActiveRecord::Migration
  def change
    rename_column :pages, :meta_tags, :head_tags
  end
end
