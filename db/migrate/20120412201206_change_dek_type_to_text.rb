class ChangeDekTypeToText < ActiveRecord::Migration
  def change
    change_column :readability_data, :dek, :text
  end
end
