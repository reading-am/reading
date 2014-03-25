class CreateDescribeData < ActiveRecord::Migration
  def change
    create_table :describe_data do |t|
      t.text :response
      t.references :page, index: true
      
      t.timestamps
    end
  end
end
