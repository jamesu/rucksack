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

ActiveRecord::Schema.define(:version => 9) do

  create_table "accounts", :force => true do |t|
    t.integer  "owner_id",   :limit => 10,                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site_name",  :limit => 100, :default => "", :null => false
  end

  create_table "application_logs", :force => true do |t|
    t.integer  "rel_object_id",   :limit => 10, :default => 0,     :null => false
    t.text     "object_name"
    t.string   "rel_object_type", :limit => 50
    t.datetime "created_on",                                       :null => false
    t.integer  "created_by_id",   :limit => 10
    t.boolean  "is_private",                    :default => false, :null => false
    t.boolean  "is_silent",                     :default => false, :null => false
    t.integer  "action_id",       :limit => 1
    t.integer  "page_id",         :limit => 10
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

  create_table "page_slots", :force => true do |t|
    t.integer "page_id",         :limit => 10
    t.integer "rel_object_id",   :limit => 10, :default => 0, :null => false
    t.string  "rel_object_type", :limit => 30
    t.integer "position",        :limit => 10, :default => 0, :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "title",         :limit => 100
    t.integer  "created_by_id", :limit => 10
    t.integer  "updated_by_id", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",                    :default => false, :null => false
  end

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

  create_table "users", :force => true do |t|
    t.string   "username",      :limit => 50,  :default => "", :null => false
    t.string   "email",         :limit => 100
    t.string   "token",         :limit => 40,  :default => "", :null => false
    t.string   "salt",          :limit => 13,  :default => "", :null => false
    t.string   "twister",       :limit => 10,  :default => "", :null => false
    t.string   "identity_url"
    t.string   "display_name",  :limit => 50
    t.string   "avatar_file",   :limit => 44
    t.string   "time_zone",                                    :null => false
    t.integer  "created_by_id", :limit => 10
    t.datetime "last_login"
    t.datetime "last_visit"
    t.datetime "last_activity"
    t.boolean  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",    :limit => 10
  end

end
