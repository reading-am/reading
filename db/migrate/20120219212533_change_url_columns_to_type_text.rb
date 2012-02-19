class ChangeUrlColumnsToTypeText < ActiveRecord::Migration
  def change
    change_column :readability_data, :url, :text
  end
end
