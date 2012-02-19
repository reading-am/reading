class ChangeReadabilityAuthorColumnToTextType < ActiveRecord::Migration
  def change
    change_column :readability_data, :author, :text
  end
end
