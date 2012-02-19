class AddExcerptToReadabilityData < ActiveRecord::Migration
  def change
    add_column :readability_data, :excerpt, :string
  end
end
