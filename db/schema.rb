# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 15) do

  create_table "accounts", :force => true do |t|
    t.integer  "owner_id",   :limit => 10,                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site_name",  :limit => 100, :default => "", :null => false
  end

  create_table "application_logs", :force => true do |t|
    t.integer  "rel_object_id",    :limit => 10
    t.text     "object_name"
    t.string   "rel_object_type",  :limit => 50
    t.datetime "created_on"
    t.integer  "created_by_id",    :limit => 10
    t.boolean  "is_private"
    t.boolean  "is_silent"
    t.integer  "action_id",        :limit => 1
    t.integer  "page_id",          :limit => 10
    t.text     "previous_name"
    t.integer  "modified_page_id", :limit => 10
  end

  add_index "application_logs", ["modified_page_id", "created_by_id"], :name => "index_application_logs_on_modified_page_id_and_created_by_id"
  add_index "application_logs", ["rel_object_id", "rel_object_type"], :name => "index_application_logs_on_rel_object_id_and_rel_object_type"

  create_table "emails", :force => true do |t|
    t.integer  "page_id",       :limit => 10
    t.string   "subject"
    t.text     "body"
    t.integer  "created_by_id", :limit => 10, :default => 0, :null => false
    t.integer  "updated_by_id", :limit => 10, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favourite_pages", :id => false, :force => true do |t|
    t.integer "page_id", :limit => 10
    t.integer "user_id", :limit => 10
  end

  create_table "journals", :force => true do |t|
    t.integer  "user_id",    :limit => 10, :null => false
    t.string   "content",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journals", ["user_id"], :name => "index_journals_on_user_id"

  create_table "list_items", :force => true do |t|
    t.integer  "list_id",         :limit => 10
    t.text     "content"
    t.datetime "completed_on"
    t.integer  "completed_by_id", :limit => 10
    t.integer  "created_by_id",   :limit => 10
    t.integer  "updated_by_id",   :limit => 10
    t.integer  "position",        :limit => 10, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "list_items", ["list_id"], :name => "index_list_items_on_list_id"

  create_table "lists", :force => true do |t|
    t.integer  "page_id",         :limit => 10
    t.integer  "priority"
    t.string   "name",            :limit => 100
    t.datetime "completed_on"
    t.integer  "completed_by_id", :limit => 10
    t.integer  "created_by_id",   :limit => 10,  :default => 0, :null => false
    t.integer  "updated_by_id",   :limit => 10,  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lists", ["page_id"], :name => "index_lists_on_page_id"

  create_table "notes", :force => true do |t|
    t.integer  "page_id",       :limit => 10
    t.string   "title",         :limit => 100
    t.text     "content"
    t.integer  "created_by_id", :limit => 10,  :default => 0,     :null => false
    t.integer  "updated_by_id", :limit => 10,  :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_date",                    :default => false, :null => false
  end

  add_index "notes", ["page_id"], :name => "index_notes_on_page_id"

  create_table "page_slots", :force => true do |t|
    t.integer "page_id",         :limit => 10
    t.integer "rel_object_id",   :limit => 10, :default => 0, :null => false
    t.string  "rel_object_type", :limit => 30
    t.integer "position",        :limit => 10, :default => 0, :null => false
  end

  add_index "page_slots", ["page_id"], :name => "index_page_slots_on_page_id"
  add_index "page_slots", ["rel_object_id", "rel_object_type"], :name => "index_page_slots_on_rel_object_id_and_rel_object_type"

  create_table "pages", :force => true do |t|
    t.string   "title",         :limit => 100
    t.integer  "created_by_id", :limit => 10
    t.integer  "updated_by_id", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",                    :default => false, :null => false
    t.integer  "width",                        :default => 400,   :null => false
    t.string   "address",       :limit => 50
  end

  add_index "pages", ["created_by_id"], :name => "index_pages_on_created_by_id"

  create_table "reminders", :force => true do |t|
    t.text     "content"
    t.datetime "at_time"
    t.integer  "repeat_id",     :limit => 1,  :default => 0,     :null => false
    t.boolean  "sent",                        :default => false, :null => false
    t.integer  "created_by_id", :limit => 10
    t.integer  "updated_by_id", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "separators", :force => true do |t|
    t.integer  "page_id",       :limit => 10
    t.string   "title",         :limit => 100
    t.integer  "created_by_id", :limit => 10,  :default => 0, :null => false
    t.integer  "updated_by_id", :limit => 10,  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "separators", ["page_id"], :name => "index_separators_on_page_id"

  create_table "shared_pages", :id => false, :force => true do |t|
    t.integer "page_id", :limit => 10
    t.integer "user_id", :limit => 10
  end

  create_table "statuses", :force => true do |t|
    t.integer  "user_id",    :limit => 10, :null => false
    t.text     "content",                  :null => false
    t.datetime "updated_on"
  end

  create_table "tags", :force => true do |t|
    t.integer  "page_id",         :limit => 10
    t.string   "name",            :limit => 30, :default => "", :null => false
    t.integer  "rel_object_id",                 :default => 0,  :null => false
    t.string   "rel_object_type", :limit => 50
    t.datetime "created_on"
    t.integer  "created_by_id",   :limit => 10, :default => 0,  :null => false
  end

  add_index "tags", ["rel_object_id", "rel_object_type"], :name => "index_tags_on_rel_object_id_and_rel_object_type"
  add_index "tags", ["name"], :name => "index_tags_on_name"
  add_index "tags", ["page_id"], :name => "index_tags_on_page_id"

  create_table "uploaded_files", :force => true do |t|
    t.integer  "page_id",           :limit => 10
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "created_by_id",     :limit => 10, :default => 0, :null => false
    t.integer  "updated_by_id",     :limit => 10, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username",                  :limit => 50,  :default => "", :null => false
    t.string   "email",                     :limit => 100
    t.string   "token",                     :limit => 40,  :default => "", :null => false
    t.string   "salt",                      :limit => 13,  :default => "", :null => false
    t.string   "twister",                   :limit => 10,  :default => "", :null => false
    t.string   "identity_url"
    t.string   "display_name",              :limit => 50
    t.string   "time_zone",                                                :null => false
    t.integer  "created_by_id",             :limit => 10
    t.datetime "last_login"
    t.datetime "last_visit"
    t.datetime "last_activity"
    t.boolean  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",                :limit => 10
    t.integer  "home_page_id",              :limit => 10
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true
  add_index "users", ["account_id"], :name => "index_users_on_account_id"

end
