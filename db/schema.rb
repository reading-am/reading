# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160730201516) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorizations", force: :cascade do |t|
    t.string   "provider",      limit: 255
    t.string   "uid",           limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "token"
    t.text     "secret"
    t.string   "permissions",   limit: 255
    t.text     "info"
    t.datetime "expires_at"
    t.text     "refresh_token"
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid", using: :btree
  end

  create_table "blockages", force: :cascade do |t|
    t.integer  "blocker_id"
    t.integer  "blocked_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["blocked_id"], name: "index_blockages_on_blocked_id", using: :btree
    t.index ["blocker_id", "blocked_id"], name: "index_blockages_on_blocker_id_and_blocked_id", unique: true, using: :btree
    t.index ["blocker_id"], name: "index_blockages_on_blocker_id", using: :btree
  end

  create_table "blogs", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "template"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_blogs_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.text     "body"
    t.integer  "comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "page_id"
    t.index ["comment_id"], name: "index_comments_on_comment_id", using: :btree
    t.index ["page_id"], name: "index_comments_on_page_id", using: :btree
    t.index ["post_id"], name: "index_comments_on_post_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "describe_data", force: :cascade do |t|
    t.text     "response"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["page_id"], name: "index_describe_data_on_page_id", using: :btree
  end

  create_table "domains", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verb",        limit: 255
    t.integer  "pages_count",             default: 0
    t.index ["name"], name: "index_domains_on_name", unique: true, using: :btree
  end

  create_table "hooks", force: :cascade do |t|
    t.string   "provider",         limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "params",           limit: 255
    t.string   "events",           limit: 255
    t.integer  "authorization_id"
    t.index ["user_id", "provider"], name: "index_hooks_on_user_id_and_provider", using: :btree
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id",             null: false
    t.integer  "application_id",                null: false
    t.string   "token",             limit: 255, null: false
    t.integer  "expires_in",                    null: false
    t.text     "redirect_uri",                  null: false
    t.datetime "created_at",                    null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",              limit: 255,              null: false
    t.string   "uid",               limit: 255,              null: false
    t.string   "secret",            limit: 255,              null: false
    t.text     "redirect_uri",                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type",        limit: 255
    t.string   "icon_file_name",    limit: 255
    t.string   "icon_content_type", limit: 255
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.string   "website",           limit: 255
    t.text     "description"
    t.string   "app_store_url",     limit: 255
    t.string   "play_store_url",    limit: 255
    t.string   "scopes",                        default: "", null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.text     "url"
    t.text     "title"
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "posts_count",                   default: 0
    t.integer  "comments_count",                default: 0
    t.string   "medium",            limit: 255
    t.string   "media_type",        limit: 255
    t.text     "description"
    t.text     "embed"
    t.integer  "has_describe_data",             default: 0, null: false
    t.integer  "tags_count"
    t.index ["medium"], name: "index_pages_on_medium", using: :btree
    t.index ["url"], name: "index_pages_on_url", unique: true, using: :btree
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "referrer_post_id"
    t.integer  "page_id"
    t.boolean  "yn"
    t.integer  "referring_posts_count", default: 0
    t.integer  "comments_count",        default: 0
  end

  create_table "readability_data", force: :cascade do |t|
    t.text     "content"
    t.string   "domain",         limit: 255
    t.text     "author"
    t.text     "url"
    t.string   "short_url",      limit: 255
    t.text     "title"
    t.integer  "total_pages"
    t.integer  "word_count"
    t.datetime "date_published"
    t.integer  "page_id"
    t.integer  "next_page_id"
    t.integer  "rendered_pages"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "excerpt",        limit: 255
    t.string   "direction",      limit: 255
    t.text     "dek"
    t.text     "lead_image_url"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
    t.index ["follower_id"], name: "index_relationships_on_follower_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.integer  "page_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_tags_on_name", using: :btree
    t.index ["page_id"], name: "index_tags_on_page_id", using: :btree
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", using: :btree
    t.index ["user_id", "page_id"], name: "index_tags_on_user_id_and_page_id", using: :btree
    t.index ["user_id"], name: "index_tags_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "username",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token",                  limit: 255
    t.string   "email",                  limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "location",               limit: 255
    t.string   "description",            limit: 255
    t.string   "image",                  limit: 255
    t.string   "phone",                  limit: 255
    t.string   "urls",                   limit: 255
    t.boolean  "email_when_followed",                default: true
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "bio",                    limit: 255
    t.string   "link",                   limit: 255
    t.integer  "mail_digest"
    t.integer  "access"
    t.integer  "posts_count",                        default: 0
    t.integer  "following_count",                    default: 0
    t.integer  "followers_count",                    default: 0
    t.integer  "comments_count",                     default: 0
    t.boolean  "email_when_mentioned",               default: true
    t.integer  "roles"
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.boolean  "feed_present",                       default: false
    t.integer  "status"
    t.integer  "blocking_count",                     default: 0
    t.integer  "blockers_count",                     default: 0
    t.integer  "tags_count"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["token"], name: "index_users_on_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "authorizations", "users", name: "authorizations_user_id_fk", on_delete: :cascade
  add_foreign_key "blockages", "users", column: "blocked_id", name: "blockages_blocked_id_fk", on_delete: :cascade
  add_foreign_key "blockages", "users", column: "blocker_id", name: "blockages_blocker_id_fk", on_delete: :cascade
  add_foreign_key "blogs", "users", name: "blogs_user_id_fk", on_delete: :cascade
  add_foreign_key "comments", "comments", name: "comments_comment_id_fk"
  add_foreign_key "comments", "pages", name: "comments_page_id_fk", on_delete: :cascade
  add_foreign_key "comments", "posts", name: "comments_post_id_fk", on_delete: :nullify
  add_foreign_key "comments", "users", name: "comments_user_id_fk", on_delete: :cascade
  add_foreign_key "describe_data", "pages", name: "describe_data_page_id_fk", on_delete: :cascade
  add_foreign_key "hooks", "authorizations", name: "hooks_authorization_id_fk", on_delete: :cascade
  add_foreign_key "hooks", "users", name: "hooks_user_id_fk", on_delete: :cascade
  add_foreign_key "pages", "domains", name: "pages_domain_id_fk", on_delete: :cascade
  add_foreign_key "posts", "pages", name: "posts_page_id_fk", on_delete: :cascade
  add_foreign_key "posts", "posts", column: "referrer_post_id", name: "posts_referrer_post_id_fk", on_delete: :nullify
  add_foreign_key "posts", "users", name: "posts_user_id_fk", on_delete: :cascade
  add_foreign_key "readability_data", "pages", name: "readability_data_page_id_fk", on_delete: :cascade
  add_foreign_key "relationships", "users", column: "followed_id", name: "relationships_followed_id_fk", on_delete: :cascade
  add_foreign_key "relationships", "users", column: "follower_id", name: "relationships_follower_id_fk", on_delete: :cascade
  add_foreign_key "tags", "pages", on_delete: :cascade
  add_foreign_key "tags", "users", on_delete: :cascade
end
