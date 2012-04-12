class AddDekAndLeadImageUrlToReadabilityData < ActiveRecord::Migration
  def change
    add_column :readability_data, :dek, :string

    add_column :readability_data, :lead_image_url, :text

  end
end
