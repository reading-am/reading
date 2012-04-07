class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user
      t.references :post
      t.text :body
      t.references :comment

      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :post_id
    add_index :comments, :comment_id
  end
end
