class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "authorizations", "users", name: "authorizations_user_id_fk", dependent: :delete
    add_foreign_key "blogs", "users", name: "blogs_user_id_fk", dependent: :delete
    add_foreign_key "comments", "comments", name: "comments_comment_id_fk"
    add_foreign_key "comments", "pages", name: "comments_page_id_fk", dependent: :delete
    add_foreign_key "comments", "posts", name: "comments_post_id_fk", dependent: :nullify
    add_foreign_key "comments", "users", name: "comments_user_id_fk", dependent: :delete
    add_foreign_key "describe_data", "pages", name: "describe_data_page_id_fk", dependent: :delete
    add_foreign_key "hooks", "authorizations", name: "hooks_authorization_id_fk", dependent: :delete
    add_foreign_key "hooks", "users", name: "hooks_user_id_fk", dependent: :delete
    add_foreign_key "pages", "domains", name: "pages_domain_id_fk", dependent: :delete
    add_foreign_key "posts", "pages", name: "posts_page_id_fk", dependent: :delete
    add_foreign_key "posts", "posts", name: "posts_referrer_post_id_fk", column: "referrer_post_id", dependent: :nullify
    add_foreign_key "posts", "users", name: "posts_user_id_fk", dependent: :delete
    add_foreign_key "readability_data", "pages", name: "readability_data_page_id_fk", dependent: :delete
    add_foreign_key "relationships", "users", name: "relationships_followed_id_fk", column: "followed_id", dependent: :delete
    add_foreign_key "relationships", "users", name: "relationships_follower_id_fk", column: "follower_id", dependent: :delete
  end
end
