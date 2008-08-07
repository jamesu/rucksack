class Reminder < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.text   "content"
      t.datetime "at_time"
      
      t.integer "repeat_id", :limit => 1, :default => 0, :null => false
      t.boolean "sent", :default => false, :null => false
        
      t.integer  "created_by_id",          :limit => 10
      t.integer  "updated_by_id",          :limit => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :reminders
  end
end
