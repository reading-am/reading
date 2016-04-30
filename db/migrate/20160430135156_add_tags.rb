class AddTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.references :page
      t.references :user
      t.timestamps
    end

    add_foreign_key :tags, :pages, on_delete: :cascade
    add_foreign_key :tags, :users, on_delete: :cascade

    add_index :tags, :name
    add_index :tags, :user_id
    add_index :tags, :page_id
    add_index :tags, [:user_id, :page_id]
    add_index :tags, [:user_id, :name]

    add_column :users, :tags_count, :integer
    add_column :pages, :tags_count, :integer
  end
end
