class CreateReadabilityData < ActiveRecord::Migration
  def change
    create_table :readability_data do |t|
      t.text :content
      t.string :domain
      t.string :author
      t.string :url
      t.string :short_url
      t.string :title
      t.integer :total_pages
      t.integer :word_count
      t.datetime :date_published
      t.integer :page_id
      t.integer :next_page_id
      t.integer :rendered_pages

      t.timestamps
    end
  end
end
