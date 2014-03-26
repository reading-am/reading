class DropRTitleRExcerptHeadTagsOembedHeadersFromPages < ActiveRecord::Migration
  def change
    change_table(:pages) do |t|
      t.remove :r_title
      t.remove :r_excerpt
      t.remove :head_tags
      t.remove :oembed
      t.remove :headers
    end
  end
end
