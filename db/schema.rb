# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120320230405) do

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "secret"
    t.string   "permissions"
    t.text     "info"
  end

  add_index "authorizations", ["provider", "uid"], :name => "index_authorizations_on_provider_and_uid"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "verb"
    t.integer  "pages_count", :default => 0
  end

  add_index "domains", ["name"], :name => "index_domains_on_name", :unique => true

  create_table "hooks", :force => true do |t|
    t.string   "provider"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "params"
    t.string   "events"
    t.integer  "authorization_id"
  end

  add_index "hooks", ["user_id", "provider"], :name => "index_hooks_on_user_id_and_provider"

  create_table "pages", :force => true do |t|
    t.text     "url"
    t.text     "title"
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "r_title"
    t.string   "r_excerpt"
    t.integer  "posts_count", :default => 0
  end

  add_index "pages", ["url"], :name => "index_pages_on_url", :unique => true

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "referrer_post_id"
    t.integer  "page_id"
    t.boolean  "yn"
    t.integer  "referring_posts_count", :default => 0
  end

  create_table "readability_data", :force => true do |t|
    t.text     "content"
    t.string   "domain"
    t.text     "author"
    t.text     "url"
    t.string   "short_url"
    t.text     "title"
    t.integer  "total_pages"
    t.integer  "word_count"
    t.datetime "date_published"
    t.integer  "page_id"
    t.integer  "next_page_id"
    t.integer  "rendered_pages"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "excerpt"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "auth_token"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "location"
    t.string   "description"
    t.string   "image"
    t.string   "phone"
    t.string   "urls"
    t.boolean  "wants_mail",          :default => true
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "bio"
    t.string   "link"
    t.integer  "mail_digest"
    t.integer  "access"
    t.integer  "posts_count",         :default => 0
    t.integer  "following_count",     :default => 0
    t.integer  "followers_count",     :default => 0
  end

  add_index "users", ["auth_token"], :name => "index_users_on_auth_token", :unique => true
  add_index "users", ["token"], :name => "index_users_on_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
