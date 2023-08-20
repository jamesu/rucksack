class AddIndexes < ActiveRecord::Migration[4.2]
  def self.up
    # Application logs
    add_index "application_logs", ["rel_object_id", "rel_object_type"]
    add_index "application_logs", ["modified_page_id", "created_by_id"]
    
    # Pages
    add_index "pages", ["created_by_id"]
    add_index "page_slots", ["rel_object_id", "rel_object_type"]
    add_index "page_slots", ["page_id"]
    
    # Widgets
    add_index "notes", ["page_id"]
    add_index "lists", ["page_id"]
    add_index "list_items", ["list_id"]
    add_index "separators", ["page_id"]
    
    # User objects
    add_index "journals", ["user_id"]
    
    # Page tags
    add_index "tags", ["page_id"]
    add_index "tags", ["name"]
    add_index "tags", ["rel_object_id", "rel_object_type"]
    
    # Users
    add_index "users", ["username"], :unique => true
    add_index "users", ["email"], :unique => true
    add_index "users", ["account_id"]
  end

  def self.down
    # Application logs
    remove_index "application_logs", ["rel_object_id", "rel_object_type"]
    remove_index "application_logs", ["modified_page_id", "created_by_id"]
    
    # Page slots
    remove_index "pages", ["user_id"]
    remove_index "page_slots", ["rel_object_id", "rel_object_type"]
    remove_index "page_slots", ["page_id"]
    
    # Widgets
    remove_index "notes", ["page_id"]
    remove_index "lists", ["page_id"]
    remove_index "list_items", ["list_id"]
    remove_index "separators", ["page_id"]
    
    # User objects
    remove_index "journals", ["user_id"]
    
    # Page tags
    remove_index "tags", ["page_id"]
    remove_index "tags", ["name"]
    remove_index "tags", ["rel_object_id", "rel_object_type"]

    # Users
    remove_index "users", ["username"]
    remove_index "users", ["email"]
    remove_index "users", ["account_id"]
  end
end
