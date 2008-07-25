class Initial < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
        t.string   "username",          :limit => 50,  :default => "",    :null => false
        t.string   "email",             :limit => 100
        
        t.string   "token",             :limit => 40,  :default => "",    :null => false
        t.string   "salt",              :limit => 13,  :default => "",    :null => false
        t.string   "twister",           :limit => 10,  :default => "",    :null => false
        t.string   "identity_url"
        
        t.string   "display_name",      :limit => 50
        t.string   "avatar_file",       :limit => 44
        t.string   "time_zone", :null => false
        
        t.integer  "created_by_id",     :limit => 10
        t.datetime "last_login"
        t.datetime "last_visit"
        t.datetime "last_activity"
        t.boolean  "is_admin"
        
        t.timestamps
    end
    
    create_table :notes do |t|
        t.integer  "page_id", :limit => 10
        t.string   "title",            :limit => 100
        
        t.text     "content"
        
        t.integer  "created_by_id",   :limit => 10,  :default => 0,     :null => false
        t.integer  "updated_by_id",   :limit => 10,  :default => 0,     :null => false
        
        t.timestamps
    end
    
    create_table :lists do |t|
        t.integer  "page_id", :limit => 10
        t.integer  "priority"
        
        t.string   "name",            :limit => 100
        t.datetime "completed_on"
        
        t.integer  "completed_by_id", :limit => 10
        t.integer  "created_by_id",   :limit => 10,  :default => 0,     :null => false
        t.integer  "updated_by_id",   :limit => 10,  :default => 0,     :null => false
        
        t.timestamps
    end
  
    create_table :list_items do |t|
        t.integer  "list_id",           :limit => 10
        
        t.text     "content"
        t.datetime "completed_on"
        
        t.integer  "completed_by_id",        :limit => 10
        t.integer  "created_by_id",          :limit => 10
        t.integer  "updated_by_id",          :limit => 10
        
        t.integer  "position",               :limit => 10, :default => 0, :null => false
        
        t.timestamps
    end
  
    create_table :pages do |t|
        t.string   "title",            :limit => 100
        
        t.integer  "created_by_id",          :limit => 10
        t.integer  "updated_by_id",          :limit => 10
        
        t.timestamps
    end
  
    create_table :page_slots do |t|
        t.integer  "page_id",           :limit => 10
        
        t.integer  "rel_object_id",        :limit => 10,  :default => 0,     :null => false
        t.string   "rel_object_type",      :limit => 30
        
        t.integer  "position",               :limit => 10, :default => 0, :null => false
    end

    
    create_table :application_logs do |t|
        t.integer  "taken_by_id",     :limit => 10
        t.integer  "rel_object_id",   :limit => 10, :default => 0,     :null => false
        t.text     "object_name"
        t.string   "rel_object_type", :limit => 50
        t.datetime "created_on",                                       :null => false
        t.integer  "created_by_id",   :limit => 10
        t.boolean  "is_private",                    :default => false, :null => false
        t.boolean  "is_silent",                     :default => false, :null => false
        t.integer  "action_id",       :limit => 1
    end
  end

  def self.down
    drop_table :application_logs
    drop_table :notes
    drop_table :list_items
    drop_table :lists
    drop_table :page_slots
    drop_table :pages
    drop_table :users
  end
end
