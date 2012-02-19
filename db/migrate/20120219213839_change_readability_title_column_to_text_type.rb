class ChangeReadabilityTitleColumnToTextType < ActiveRecord::Migration
  def change
    change_column :pages, :title, :text
    change_column :readability_data, :title, :text
  end
end
