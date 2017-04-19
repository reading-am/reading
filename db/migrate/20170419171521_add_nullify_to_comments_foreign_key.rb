class AddNullifyToCommentsForeignKey < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :comments, name: "comments_comment_id_fk"
    add_foreign_key "comments", "comments", name: "comments_comment_id_fk", dependent: :nullify
  end
end
