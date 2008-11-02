class MakeAlbums < ActiveRecord::Migration
  def self.up
    create_table "albums", :force => true do |t|
      t.integer  "page_id",       :limit => 10
      
      t.string   "title", :limit => 100
      
      t.integer  "created_by_id", :limit => 10,  :default => 0, :null => false
      t.integer  "updated_by_id", :limit => 10,  :default => 0, :null => false
      
      t.timestamps
    end
    
    create_table "album_pictures", :force => true do |t|
      t.integer  "album_id",       :limit => 10
      
      t.string   "caption",        :default => '', :null => false
      
      t.string   "picture_file_name"
      t.string   "picture_content_type"
      t.integer  "picture_file_size"
      
      t.integer  "created_by_id", :limit => 10,  :default => 0, :null => false
      t.integer  "updated_by_id", :limit => 10,  :default => 0, :null => false
        
      t.integer  "position",      :limit => 10, :default => 0, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :albums
    drop_table :album_pictures
  end
end
