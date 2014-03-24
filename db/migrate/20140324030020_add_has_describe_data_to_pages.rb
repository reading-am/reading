class AddHasDescribeDataToPages < ActiveRecord::Migration
  def change
    add_column :pages, :has_describe_data, :integer, null: false, default: 0
  end
end
