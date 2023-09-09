class FuncExtras < ActiveRecord::Migration[4.2]
  def self.up
    # File descriptions
    add_column :uploaded_files, 'description', :string, null: false, default: ''
    
    # Some more indexes
    add_index "statuses", ["user_id"]
    add_index "uploaded_files", ["page_id"]
    add_index "emails", ["page_id"]
    add_index "albums", ["page_id"]
    add_index "album_pictures", ["album_id"]
    
    add_index "reminders", ["created_by_id"]
  end

  def self.down
    remove_column :uploaded_files, 'description'
    
    remove_index "statuses", ["user_id"]
    remove_index "uploaded_files", ["page_id"]
    remove_index "emails", ["page_id"]
    remove_index "albums", ["page_id"]
    remove_index "album_pictures", ["album_id"]
    
    remove_index "reminders", ["created_by_id"]
  end
end
