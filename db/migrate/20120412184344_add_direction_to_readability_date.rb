class AddDirectionToReadabilityDate < ActiveRecord::Migration
  def change
    add_column :readability_data, :direction, :string
  end
end
