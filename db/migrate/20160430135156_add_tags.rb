class AddTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :tagged_pages_count
      t.timestamps
    end

    create_table :tagged_pages do |t|
      t.references :page
      t.references :user
      t.references :tag
      t.timestamps
    end

    add_foreign_key :tagged_pages, :pages, on_delete: :cascade
    add_foreign_key :tagged_pages, :users, on_delete: :cascade
    add_foreign_key :tagged_pages, :tags, on_delete: :cascade

    add_index :tagged_pages, :user_id
    add_index :tagged_pages, :page_id
    add_index :tagged_pages, :tag_id
    add_index :tagged_pages, [:user_id, :page_id]
    add_index :tagged_pages, [:user_id, :tag_id]

    add_column :users, :tagged_pages_count, :integer
    add_column :pages, :tagged_pages_count, :integer
  end
end
