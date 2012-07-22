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

ActiveRecord::Schema.define(:version => 20120719070530) do

  create_table "posts", :force => true do |t|
    t.text     "content",                   :null => false
    t.integer  "user_id",                   :null => false
    t.integer  "shadow_id",                 :null => false
    t.integer  "parent_id"
    t.integer  "view_count", :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "posts", ["content"], :name => "index_posts_on_content"
  add_index "posts", ["parent_id"], :name => "index_posts_on_parent_id"
  add_index "posts", ["shadow_id"], :name => "index_posts_on_shadow_id"
  add_index "posts", ["user_id", "content"], :name => "index_posts_on_user_id_and_content"
  add_index "posts", ["user_id", "shadow_id"], :name => "index_posts_on_user_id_and_shadow_id"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "shadows", :force => true do |t|
    t.text     "web_url",                     :null => false
    t.string   "title",       :default => ""
    t.text     "description", :default => ""
    t.integer  "post_id"
    t.datetime "created_at"
  end

  add_index "shadows", ["post_id"], :name => "index_shadows_on_post_id"
  add_index "shadows", ["title"], :name => "index_shadows_on_title"
  add_index "shadows", ["web_url"], :name => "index_shadows_on_web_url"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "posts_count",            :default => 0
    t.integer  "view_count",             :default => 0
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.string   "picture_file_size"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "visit_journals", :force => true do |t|
    t.integer  "user_id",         :null => false
    t.integer  "guest_id",        :null => false
    t.datetime "last_visited_at"
  end

  add_index "visit_journals", ["guest_id"], :name => "index_visit_journals_on_guest_id"
  add_index "visit_journals", ["user_id", "guest_id"], :name => "index_visit_journals_on_user_id_and_guest_id"
  add_index "visit_journals", ["user_id"], :name => "index_visit_journals_on_user_id"

end
