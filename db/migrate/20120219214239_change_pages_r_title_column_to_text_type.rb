class ChangePagesRTitleColumnToTextType < ActiveRecord::Migration
  def change
    change_column :pages, :r_title, :text
  end
end
