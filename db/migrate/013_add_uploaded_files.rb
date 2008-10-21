class AddUploadedFiles < ActiveRecord::Migration
  def self.up
    create_table "uploaded_files", :force => true do |t|
      t.integer  "page_id",       :limit => 10
      
      t.string   "data_file_name"
      t.string   "data_content_type"
      t.integer  "data_file_size"
      
      t.integer  "created_by_id", :limit => 10,  :default => 0, :null => false
      t.integer  "updated_by_id", :limit => 10,  :default => 0, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table "uploaded_files"
  end
end
